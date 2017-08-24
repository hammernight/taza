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
      params[:driver] ||= :watir
      method = "create_#{params[:driver]}"
      if Taza.browsers.key?(params[:browser])
        create_defined_browser(params[:browser])
      elsif self.respond_to?(method)
        send(method, params)
      else
        raise BrowserUnsupportedError,
          "Could not create a browser using `driver: #{params[:driver]}` or `browser: #{params[:browser]}`"
      end
    end

    private

    def self.create_watir(params)
      require 'watir'
      unless official_browser?(params[:browser])
        raise BrowserUnsupportedError, "`#{params[:browser]}` is not a browser supported by Watir"
      end
      Watir::Browser.new(params[:browser])
    end

    def self.create_selenium_webdriver(params)
      require 'selenium-webdriver'
      unless official_browser?(params[:browser])
        raise BrowserUnsupportedError, "`#{params[:browser]}` is not a browser supported by Selenium WebDriver"
      end
      Selenium::WebDriver.for(params[:browser])
    end

    def self.create_defined_browser(browser)
      Taza.browsers[browser].call
    end

    def self.official_browser?(name)
      ['firefox', 'chrome', 'ie'].include? name.to_s
    end
  end
  
  class BrowserUnsupportedError < StandardError; end
end

