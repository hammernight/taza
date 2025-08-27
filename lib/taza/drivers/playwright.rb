# Optional Playwright provider. Require this file to enable :playwright driver.
# Usage: require 'taza/drivers/playwright'
module Taza
  module Drivers
    module PlaywrightProvider
      def self.build(params)
        # Only require when not already loaded (to work with specs stubbing Playwright)
        require 'playwright' unless defined?(::Playwright)

        # Resolve engine: :chromium (default), :firefox, :webkit
        engine_name = (params[:browser] || :chromium).to_sym
        headless = params.key?(:headless) ? params[:headless] : true

        playwright = ::Playwright.create
        engine = playwright.public_send(engine_name)
        browser = engine.launch(headless: headless)
        context = browser.new_context
        page = context.new_page

        Taza::Browser::Session.new(
          page,
          goto_proc: ->(url) { page.goto(url) },
          close_proc: -> {
            begin
              context.close
            ensure
              begin
                browser.close
              ensure
                playwright.stop
              end
            end
          }
        )
      end
    end
  end
end

Taza::Browser.register(:playwright) do |params|
  Taza::Drivers::PlaywrightProvider.build(params)
end
