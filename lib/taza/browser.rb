module Taza
  class << self
    def browsers
      @browsers ||= ActiveSupport::HashWithIndifferentAccess.new
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
      params.symbolize_keys!
      params[:browser] = params[:browser].to_sym
      params[:driver] = params[:driver].to_sym if params[:driver]
      raise BrowserUnknownError unless Taza.browsers.key?(params[:browser])
      build_browser(params[:browser], params[:driver])
    end

    private
    
    def self.build_browser(browser, driver)
      browser_instance = Taza.browsers[browser].call
      raise BrowserUnsupportedError unless supported_driver?(browser_instance)
      if selenium_webdriver?(browser_instance) && driver.eql?(:watir)
        Watir::Browser.new browser_instance
      else
        browser_instance
      end
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

  end

  [:firefox, :chrome, :ie, :phantomjs].each do |browser|
    Taza.define_browser browser do
      Selenium::WebDriver.for browser
    end
  end

  class BrowserUnknownError < StandardError; end
  class BrowserUnsupportedError < StandardError; end
end

