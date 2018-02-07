module Taza
  class Browser

    # Create a browser instance depending on configuration.  Configuration should be read in via Taza::Settings.config.
    #
    # Example:
    #     browser = Taza::Browser.create(Taza::Settings.config)
    #
    def self.create(params={})
      self.send("create_#{params[:driver]}".to_sym,params)
    end

    def self.browser_class(params)
      self.send("#{params[:driver]}_#{params[:browser]}".to_sym)
    end

    private

    def self.create_watir(params)
      require 'watir'
      Watir::Browser.new(params[:browser])
    end

    def self.create_selenium(params)
      require 'selenium'
      Selenium::SeleniumDriver.new(params[:server_ip],params[:server_port],'*' + params[:browser].to_s,params[:timeout])
    end

    def self.create_selenium_webdriver(params)
      require 'selenium-webdriver'
      #Small hack. :)
      Selenium::WebDriver::Driver.class_eval do
        def goto(params)
          navigate.to params
        end
      end
      Selenium::WebDriver.for params[:browser].to_sym
    end
  end
end

