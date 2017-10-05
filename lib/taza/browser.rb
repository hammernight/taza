module Taza
  class << self
    def browsers
      @browsers ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def define_browser_with_watir(name, params = {})
      browser = params && params.key?(:browser) ? params[:browser] : name
      define_browser name do
        Watir::Browser.new(browser, params)
      end
    end
    
    def define_browser_with_selenium_webdriver(name, params = {})
      browser = params.key?(:browser) ? params[:browser] : name
      define_browser name do
        Selenium::WebDriver.for(browser, params)
      end
    end
     
    def define_browser(name, &block)
      browsers[name] = block
    end

  end

  class Browser
    # Create a browser instance depending on configuration.  Configuration should be read in via Taza::Settings.config.
    #
    # Example:
    #     browser = Taza::Browser.create(Taza::Settings.config)
    #
    def self.create(params={})
      # params.deep_symbolize_keys!
      raise BrowserConfigurationError, 
        ':browser parameter is missing or nil' unless params[:browser]
      browser, driver = params[:browser].to_sym, params[:driver]
      if Taza.browsers.key?(browser)
        create_defined_browser(browser)
      else
        create_common_browser(browser, driver, params[browser])
      end
    end

    private

    def self.create_common_browser(browser, driver = nil, params = {})
      raise BrowserUnsupportedError, 
        "`#{browser}` is not a common browser" unless common_browser?(browser)
      driver ||= 'watir'
      Taza.send("define_browser_with_#{driver}", browser, params)
      Taza.browsers[browser].call
    end

    def self.create_defined_browser(browser)
      browser_instance = Taza.browsers[browser].call
      raise BrowserUnsupportedError unless supported_driver?(browser_instance)
      browser_instance
    end

    def self.supported_driver?(browser_instance)
      watir?(browser_instance) || selenium_webdriver?(browser_instance)
    end

    def self.watir?(browser_instance)
      browser_instance.is_a? Watir::Browser
    end

    def self.selenium_webdriver?(browser_instance)
      browser_instance.is_a? Selenium::WebDriver::Driver
    end

    def self.common_browser?(browser)
      ['firefox', 'chrome', 'ie'].include? browser.to_s
    end
  end

  class BrowserUnsupportedError < StandardError; end
  class BrowserConfigurationError < StandardError; end
end

