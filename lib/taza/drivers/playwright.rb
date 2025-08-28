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

        # Resolve the Playwright CLI path if needed by the client library.
        # Priority: explicit param -> ENV -> default to 'npx playwright'
        cli_path = params[:playwright_cli_executable_path] || ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH'] || ENV['PLAYWRIGHT_CLI'] || 'npx playwright'

        # Some versions of playwright-ruby-client require a keyword, others accept none.
        # Introspect the create signature to decide.
        create_params = begin
          ::Playwright.method(:create).parameters
        rescue NameError
          []
        end

        runtime = if create_params.any? { |(kind, _name)| [:key, :keyreq, :keyrest].include?(kind) }
          ::Playwright.create(playwright_cli_executable_path: cli_path)
        else
          ::Playwright.create
        end

        # Newer versions return a Playwright::Execution with #playwright accessor for BrowserTypes.
        base = runtime.respond_to?(:playwright) ? runtime.playwright : runtime

        engine = base.public_send(engine_name)
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
                # Stop the runtime appropriately
                if runtime.respond_to?(:stop)
                  runtime.stop
                elsif base.respond_to?(:stop)
                  base.stop
                end
              end
            end
          }
        )

        # Helper to register events across client versions (two-arg vs block API)
        register = lambda do |emitter, event, &blk|
          begin
            # Try two-arg style first (newer clients)
            emitter.on(event, blk)
          rescue ArgumentError
            # Fallback to block style (older clients / fakes)
            emitter.on(event, &blk)
          rescue NoMethodError
            # ignore for mocks that don't implement .on
          end
        end

        # Optional event bridging
        begin
          register.call(page, :console) { |message|
            Taza::Events.publish(:console, { session: session, message: message })
          }
        rescue NoMethodError
        end

        begin
          register.call(page, :dialog) { |dialog|
            Taza::Events.publish(:dialog_open, { session: session, dialog: dialog })
          }
        rescue NoMethodError
        end

        begin
          register.call(context, :request) do |request|
            Taza::Events.publish(:request, { session: session, request: request })
          end
          register.call(context, :response) do |response|
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
