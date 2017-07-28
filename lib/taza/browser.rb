module Taza
  class Browser

    # Create a browser instance depending on configuration.  Configuration should be read in via Taza::Settings.config.
    #
    # Example:
    #     browser = Taza::Browser.create(Taza::Settings.config)
    #
    def self.create(params={}, *args)
      params[:driver] ||= 'watir'
      send("create_#{params[:driver]}", params, *args)
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
end

