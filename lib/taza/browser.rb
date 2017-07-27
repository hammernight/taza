module Taza
  class Browser

    # Create a browser instance depending on configuration.  Configuration should be read in via Taza::Settings.config.
    #
    # Example:
    #     browser = Taza::Browser.create(Taza::Settings.config)
    #
    def self.create(params={})
      create_watir(params)
    end

    private

    def self.create_watir(params)
      require 'watir'
      Watir::Browser.new(params[:browser])
    end
  end
end

