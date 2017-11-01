module Taza
  class << self
    def browsers
      @browsers ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def define_browser_with_watir(name, params = {})
      browser = params && params[:browser] ? params.delete(:browser) : name
      define_browser name do
        Watir::Browser.new(browser.to_sym, params)
      end
    end
    
    def define_browser_with_selenium_webdriver(name, params = {})
      browser = params && params[:browser] ? params.delete(:browser) : name
      define_browser name do
        Selenium::WebDriver.for(browser.to_sym, params)
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
    def self.create(browser, driver = 'watir', params={})
      browser = browser.to_sym
      driver = driver.to_sym
      if Taza.browsers.key?(browser)
        create_defined_browser(browser)
      else
        create_common_browser(browser, driver, params)
      end
    end

    private

    def self.create_common_browser(browser, driver, params = {})
      raise BrowserNotDefinedError, 
        "`#{browser}` browser is undefined." unless common_browser?(browser)
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
  class BrowserNotDefinedError < StandardError; end
end

