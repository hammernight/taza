module Taza
  class Browser
    # A tiny wrapper around the underlying automation object(s).
    # Providers must supply goto and close behavior via procs.
    class Session
      attr_reader :raw
      def initialize(raw, goto_proc:, close_proc:)
        @raw = raw
        @goto_proc = goto_proc
        @close_proc = close_proc
      end

      def goto(url)
        Taza::Events.publish(:before_navigate, { session: self, url: url })
        begin
          @goto_proc.call(url)
          Taza::Events.publish(:after_navigate, { session: self, url: url })
        rescue => e
          mapped = Taza::Browser.normalize_exception(e)
          raise mapped, "#{e.class}: #{e.message}", cause: e
        end
      end

      def close
        begin
          @close_proc.call
          Taza::Events.publish(:session_closed, { session: self })
        rescue => e
          mapped = Taza::Browser.normalize_exception(e)
          raise mapped, "#{e.class}: #{e.message}", cause: e
        end
      end

      def method_missing(name, *args, &block)
        if @raw.respond_to?(name)
          @raw.public_send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @raw.respond_to?(name, include_private) || super
      end
    end

    SPI_VERSION = 1

    class << self
      def register(name, builder = nil, &block)
        raise ArgumentError, 'name is required' if name.nil?
        callable = builder || block
        raise ArgumentError, 'builder or block is required' unless callable
        registry[name.to_sym] = callable
      end

      def unregister(name)
        registry.delete(name.to_sym)
      end

      def reset_registry!
        @registry = {}
        install_builtin_providers!
      end

      def registry
        @registry ||= {}
      end

      # Optional plugin discovery for external adapters.
      def autoload_plugins_enabled?
        ENV['TAZA_AUTOLOAD_DRIVERS'] == '1'
      end

      def load_plugins!
        return if @plugins_loaded
        begin
          Kernel.require 'rubygems'
          plugins = Gem.find_files('taza/drivers/*.rb')
          plugins.each do |path|
            begin
              Kernel.require path
            rescue LoadError
              # Ignore broken plugin requires; user will see unknown driver error later
            end
          end
        rescue StandardError
          # Ignore discovery errors entirely; fall back to on-demand require
        ensure
          @plugins_loaded = true
        end
      end

      def coerce_options(opts)
        coerced = opts.dup
        if coerced.key?(:headless)
          v = coerced[:headless]
          if v.is_a?(String)
            lowered = v.strip.downcase
            coerced[:headless] = %w[true 1 yes y].include?(lowered) ? true : (%w[false 0 no n].include?(lowered) ? false : v)
          end
        end
        coerced
      end

      def validate_options!(opts)
        raise ArgumentError, 'driver is required (e.g., :watir, :selenium_webdriver, :playwright)' if opts[:driver].nil? || opts[:driver] == ''
        if opts.key?(:headless) && !(opts[:headless] == true || opts[:headless] == false)
          raise ArgumentError, 'headless must be a boolean (true/false)'
        end
      end

      # Create a browser session depending on configuration.
      # Prefers registered providers; falls back to legacy create_<driver> methods.
      # Example:
      #   browser = Taza::Browser.create(Taza::Settings.config)
      def create(params = {})
        # Optionally autoload all plugins once
        load_plugins! if autoload_plugins_enabled?

        driver = (params[:driver] || params['driver'])
        browser = (params[:browser] || params['browser'])
        normalized = params.dup
        normalized[:driver] = (driver.is_a?(String) ? driver.to_sym : driver)
        normalized[:browser] = (browser.is_a?(String) ? browser.to_sym : browser)

        normalized = coerce_options(normalized)
        validate_options!(normalized)

        if registry.key?(normalized[:driver])
          builder = registry[normalized[:driver]]
          return builder.call(normalized)
        end

        # Attempt to auto-load adapter provider by convention
        begin
          require "taza/drivers/#{normalized[:driver]}"
        rescue LoadError
          # ignore, will fall back below
        end

        if registry.key?(normalized[:driver])
          builder = registry[normalized[:driver]]
          return builder.call(normalized)
        end

        # Legacy fallback to existing create_<driver> methods.
        legacy_method = "create_#{normalized[:driver]}".to_sym
        if respond_to?(legacy_method)
          return send(legacy_method, normalized)
        end

        raise StandardError, "Unknown driver: #{driver.inspect}. Register an adapter with Taza::Browser.register(:#{driver})"
      end

      # Kept for compatibility with specs that rely on this behavior.
      def browser_class(params)
        self.send("#{params[:driver]}_#{params[:browser]}".to_sym)
      end

      def normalize_exception(e)
        klass_name = e.class.name.to_s
        msg = e.message.to_s

        # Explicit checks for Selenium exceptions when available
        begin
          if defined?(::Selenium::WebDriver::Error::NoSuchElementError) && e.is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
            return Taza::Errors::ElementNotFound
          end
          if defined?(::Selenium::WebDriver::Error::StaleElementReferenceError) && e.is_a?(::Selenium::WebDriver::Error::StaleElementReferenceError)
            return Taza::Errors::StaleElement
          end
          if defined?(::Selenium::WebDriver::Error::UnhandledAlertError) && e.is_a?(::Selenium::WebDriver::Error::UnhandledAlertError)
            return Taza::Errors::DialogError
          end
          if defined?(::Selenium::WebDriver::Error::TimeoutError) && e.is_a?(::Selenium::WebDriver::Error::TimeoutError)
            return Taza::Errors::TimeoutError
          end
        rescue NameError
          # ignore constant resolution issues if selenium-webdriver is not loaded
        end

        # Explicit checks for Watir exceptions when available
        begin
          if defined?(::Watir::Exception::UnknownObjectException) && e.is_a?(::Watir::Exception::UnknownObjectException)
            return Taza::Errors::ElementNotFound
          end
          if defined?(::Watir::Wait::TimeoutError) && e.is_a?(::Watir::Wait::TimeoutError)
            return Taza::Errors::TimeoutError
          end
        rescue NameError
          # ignore constant resolution issues if watir is not loaded
        end

        # Prefer class-name based detection first
        return Taza::Errors::ElementNotFound if klass_name =~ /(NoSuchElement|UnknownObject|ElementNotFound)/i
        return Taza::Errors::StaleElement    if klass_name =~ /StaleElement/i
        return Taza::Errors::DialogError     if klass_name =~ /(UnhandledAlert|Alert|Dialog)/i
        return Taza::Errors::TimeoutError    if klass_name =~ /Timeout/i

        # Fallback to message-based hints
        return Taza::Errors::ElementNotFound if msg =~ /(no such element|unknown object|element not found)/i
        return Taza::Errors::StaleElement    if msg =~ /stale element/i
        return Taza::Errors::DialogError     if msg =~ /(unhandled alert|alert|dialog)/i
        return Taza::Errors::TimeoutError    if msg =~ /timeout/i

        # Default to NavigationError for operations in Session
        Taza::Errors::NavigationError
      end

      private

      def install_builtin_providers!
        # Built-in provider: Watir -> Session
        register(:watir) do |params|
          require 'watir' unless defined?(::Watir::Browser)
          raw = ::Watir::Browser.new(params[:browser])
          Session.new(raw,
            goto_proc: ->(url) { raw.goto(url) },
            close_proc: -> { raw.close }
          )
        end

        # Built-in provider: Selenium WebDriver -> Session
        register(:selenium_webdriver) do |params|
          require 'selenium-webdriver' unless defined?(::Selenium::WebDriver)
          browser_sym = params[:browser].to_sym
          options = params[:options]

          created_profile_dir = nil
          env_truthy = ->(name) do
            v = ENV[name]
            next false if v.nil?
            %w[1 true yes y].include?(v.to_s.strip.downcase)
          end
          ensure_unique_profile = (env_truthy.call('TAZA_SELENIUM_UNIQUE_PROFILE') || env_truthy.call('CI'))
          force_unique_profile = env_truthy.call('TAZA_SELENIUM_FORCE_UNIQUE_PROFILE')

          if (ensure_unique_profile || force_unique_profile) && [:chrome, :chromium, :edge].include?(browser_sym)
            require 'tmpdir'
            require 'fileutils'
            begin
              if options.nil?
                created_profile_dir = Dir.mktmpdir('taza-selenium-profile-')
                opts_class = (browser_sym == :edge ? ::Selenium::WebDriver::Edge::Options : ::Selenium::WebDriver::Chrome::Options)
                options = opts_class.new
                options.add_argument("--user-data-dir=#{created_profile_dir}")
                if env_truthy.call('CI')
                  options.add_argument('--headless=new')
                  options.add_argument('--disable-gpu')
                  options.add_argument('--no-sandbox')
                  options.add_argument('--disable-dev-shm-usage')
                end
                options.add_argument('--no-first-run')
                options.add_argument('--no-default-browser-check')
              else
                args = []
                begin
                  args = options.respond_to?(:args) ? Array(options.args) : []
                rescue StandardError
                  args = []
                end
                has_ud = args.any? { |a| a.to_s.include?('--user-data-dir=') }
                if force_unique_profile || !has_ud
                  created_profile_dir = Dir.mktmpdir('taza-selenium-profile-')
                  options.add_argument("--user-data-dir=#{created_profile_dir}") if options.respond_to?(:add_argument)
                end
              end
            rescue StandardError
              created_profile_dir = nil
            end
          end

          raw = if options
            ::Selenium::WebDriver.for(browser_sym, options: options)
          else
            ::Selenium::WebDriver.for(browser_sym)
          end

          close_proc = proc do
            raw.quit
            if created_profile_dir && Dir.exist?(created_profile_dir)
              begin
                FileUtils.remove_entry_secure(created_profile_dir)
              rescue StandardError
                # ignore cleanup errors
              end
            end
          end

          Session.new(raw,
            goto_proc: ->(url) { raw.navigate.to(url) },
            close_proc: close_proc
          )
        end
      end
    end

    # Initialize built-ins at load time
    install_builtin_providers!

    # Legacy creators kept for backward compatibility with existing tests and configs.
    def self.create_watir(params)
      require 'watir'
      Watir::Browser.new(params[:browser])
    end

    def self.create_selenium(params)
      Kernel.warn('[DEPRECATION] Taza::Browser#create_selenium (Selenium RC) is deprecated and will be removed in a future release. Use driver: :selenium_webdriver instead.')
      require 'selenium'
      Selenium::SeleniumDriver.new(params[:server_ip], params[:server_port], '*' + params[:browser].to_s, params[:timeout])
    end

    def self.create_selenium_webdriver(params)
      require 'selenium-webdriver' unless defined?(::Selenium::WebDriver)
      browser_sym = params[:browser].to_sym
      if params[:options]
        Selenium::WebDriver.for(browser_sym, options: params[:options])
      else
        Selenium::WebDriver.for browser_sym
      end
    end
  end
end
