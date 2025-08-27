# Adding a Browser Adapter to Taza

This guide shows how to add a new browser/automation tool to Taza via the pluggable adapter API.

At a glance
- Implement a builder that returns Taza::Browser::Session with two methods:
  - goto(url)
  - close
- Register your adapter with Taza::Browser.register(:name) when your file is required.
- Keep your adapter self-contained (require its gem internally) and translate between Taza’s minimal API and the tool’s native API.

Why this design?
- Taza uses a tiny, stable Surface: a Session with goto and close. Everything else is forwarded to the underlying native driver for compatibility.
- Drivers (adapters) are optional and loaded on demand, making Taza easy to extend without core changes.

Prerequisites
- Ruby 2.7+
- Familiarity with your automation tool’s API and lifecycle (start, navigate, teardown)

File layout
- Place your adapter in lib/taza/drivers/<name>.rb.
- Register it when required.

Minimal contract
- Adapter SPI version: Taza::Browser::SPI_VERSION (currently 1)
- Build signature: .build(params) => returns Taza::Browser::Session
- Session must:
  - call goto_proc for navigation
  - call close_proc for teardown
  - forward unknown methods to the native driver (provided by Session already)

Example: A skeleton adapter
```ruby
# lib/taza/drivers/acme.rb
module Taza
  module Drivers
    class Acme
      ADAPTER_SPI_VERSION = Taza::Browser::SPI_VERSION

      def self.build(params)
        require 'acme-web' # your gem

        # Map common options
        browser = (params[:browser] || :chrome).to_sym
        headless = params.key?(:headless) ? params[:headless] : true

        # Start native objects (adjust for your tool)
        raw = ::Acme::Client.start(browser: browser, headless: headless)

        # Wrap in a Taza::Browser::Session
        Taza::Browser::Session.new(
          raw,
          goto_proc: ->(url) { raw.navigate_to(url) },
          close_proc: -> { raw.shutdown }
        )
      end

      # Optional: advertise adapter capabilities
      def self.capabilities
        { tabs: true, downloads: false, tracing: false }
      end

      # Optional: validate options (if you use a schema lib)
      # def self.option_schema; end
    end
  end
end

# Register with the registry when this file is required
Taza::Browser.register(:acme) { |params| Taza::Drivers::Acme.build(params) }
```

Parameters provided to build(params)
- driver: Symbol (your adapter name)
- browser: Symbol (engine/flavor, if applicable) e.g., :chrome, :firefox
- headless: boolean
- extra: Hash (any other free-form options)
- You can also use your own keys; consumers pass them through Settings.config.

How to use your adapter in a project
1) Add the gem dependency (your tool + your adapter, if separate):
   - gem 'acme-web'
   - require 'taza/drivers/acme'
2) Configure config/config.yml:
   - driver: acme
   - browser: chrome
   - headless: true
3) Use as usual in tests; Taza::Site will create the session and navigate to the configured url automatically.

Testing your adapter
- Unit test your builder: stub your gem’s classes to avoid launching real browsers.
- Contract tests (recommended): write specs that assert
  - session.goto(url) routes to native navigation
  - session.close disposes resources in the right order
  - unknown methods are forwarded to the raw driver
- See: spec/taza/adapter_contract_spec.rb and spec/taza/playwright_provider_spec.rb for patterns.

Error handling and events (recommended)
- Map native errors to Taza::Errors (e.g., NavigationError, TimeoutError) where practical.
- Emit Taza::Events where relevant; Taza::Browser::Session already emits before_navigate, after_navigate, and session_closed.

Publishing as a plugin (optional)
- Name your gem like taza-driver-<name> and ship lib/taza/drivers/<name>.rb that registers the adapter.
- Consumers can add the gem and require 'taza/drivers/<name>' to enable it.

Troubleshooting
- LoadError for your gem
  - Ensure your adapter requires the gem internally; don’t make Taza core depend on it.
- Missing methods on session
  - Only goto and close are required; additional calls are forwarded to the raw driver.
- Conflicting constants
  - In tests, stub Kernel.require and driver constants. Avoid global modifications in your adapter.

