# Minimal custom adapter for demo purposes
module Taza
  module Drivers
    class Acme
      ADAPTER_SPI_VERSION = Taza::Browser::SPI_VERSION

      class FakeRaw
        attr_reader :last_url
        def element(**locator)
          FakeElement.new(locator)
        end
        def navigate_to(url)
          @last_url = url
        end
      end

      class FakeElement
        def initialize(locator)
          @locator = locator
        end
        def visible?
          true
        end
        def click; end
        def text; @locator.inspect; end
        def set(_v); end
      end

      def self.build(params)
        raw = FakeRaw.new
        Taza::Browser::Session.new(
          raw,
          goto_proc: ->(url) { raw.navigate_to(url) },
          close_proc: -> { }
        )
      end
    end
  end
end

Taza::Browser.register(:acme) { |params| Taza::Drivers::Acme.build(params) }

