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

        session = Taza::Browser::Session.new(
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

        # Optional event bridging
        begin
          # Console messages
          page.on(:console) do |message|
            Taza::Events.publish(:console, { session: session, message: message })
          end
        rescue NoMethodError
          # page.on might not exist on mocks; ignore
        end

        begin
          # Dialog open
          page.on(:dialog) do |dialog|
            Taza::Events.publish(:dialog_open, { session: session, dialog: dialog })
          end
        rescue NoMethodError
        end

        begin
          # Network request/response
          context.on(:request) do |request|
            Taza::Events.publish(:request, { session: session, request: request })
          end
          context.on(:response) do |response|
            Taza::Events.publish(:response, { session: session, response: response })
          end
        rescue NoMethodError
        end

        session
      end
    end
  end
end

Taza::Browser.register(:playwright) do |params|
  Taza::Drivers::PlaywrightProvider.build(params)
end
