module Taza
  class Browser

    # Create a browser instance depending on configuration.  Configuration should be read in via Taza::Settings.config.
    #
    # Example:
    #     browser = Taza::Browser.create(Taza::Settings.config)
    #
    def self.create(params={}, *args)
      params[:driver] ||= 'watir'
      method = "create_#{params[:driver]}"
      if self.respond_to?(method)
        send(method, params, *args)
      else
        raise BrowserUnsupportedError, "Could not create browser using `#{params[:driver]}`"
      end
    end

    private

    def self.create_watir(params, *args)
      require 'watir'
      Watir::Browser.new(params[:browser].to_sym, *args)
    end

    def self.create_selenium_webdriver(params, *args)
      require 'selenium-webdriver'
      Selenium::WebDriver.for(params[:browser].to_sym, *args)
    end
  end

  class BrowserUnsupportedError < StandardError; end
end

