module Taza
  module Elements
    class Element
      attr_reader :raw, :session, :locator

      def initialize(session, raw, locator = nil)
        @session = session
        @raw = raw
        @locator = locator
      end

      def click
        if @raw.respond_to?(:click)
          @raw.click
        else
          raise NoMethodError, 'click not supported by underlying element'
        end
      end

      def text
        if @raw.respond_to?(:text)
          @raw.text
        elsif @raw.respond_to?(:inner_text)
          @raw.inner_text
        else
          nil
        end
      end

      def visible?
        if @raw.respond_to?(:visible?)
          @raw.visible?
        elsif @raw.respond_to?(:present?)
          @raw.present?
        elsif @raw.respond_to?(:displayed?)
          @raw.displayed?
        else
          true
        end
      end
      alias_method :present?, :visible?

      def fill(value)
        if @raw.respond_to?(:fill)
          @raw.fill(value)
        elsif @raw.respond_to?(:set)
          @raw.set(value)
        elsif @raw.respond_to?(:type)
          @raw.type(value)
        elsif @raw.respond_to?(:send_keys)
          @raw.clear if @raw.respond_to?(:clear)
          @raw.send_keys(value)
        else
          raise NoMethodError, 'fill not supported by underlying element'
        end
      end
      alias_method :set, :fill

      def exist?
        if @raw.respond_to?(:exists?)
          @raw.exists?
        elsif @raw.respond_to?(:exist?)
          @raw.exist?
        else
          true
        end
      end

      def wait_for_visible(timeout: 5, interval: 0.1)
        start = Time.now
        until visible?
          raise Taza::Errors::TimeoutError, 'wait_for_visible timed out' if Time.now - start > timeout
          sleep interval
        end
        true
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

    # Find an element for the given locator on the provided session
    # locator examples: { css: '#id' }, { xpath: "//div" }, { id: 'foo' }, { name: 'bar' }
    def self.find(session, locator)
      raw = session.raw
      key, value = normalize_locator(locator)

      # Watir
      if raw.respond_to?(:element)
        # Pass keyword arguments to satisfy Ruby 3 kwarg semantics
        element = raw.public_send(:element, **locator)
        return Element.new(session, element, locator)
      end

      # Selenium WebDriver
      if raw.respond_to?(:find_element)
        by = selenium_by_from(key)
        element = raw.find_element(by, value)
        return Element.new(session, element, locator)
      end

      # Playwright (prefer locator, fallback to query_selector)
      if raw.respond_to?(:locator)
        selector = playwright_selector_from(key, value)
        el = raw.locator(selector)
        return Element.new(session, el, locator)
      elsif raw.respond_to?(:query_selector)
        selector = playwright_selector_from(key, value)
        el = raw.query_selector(selector)
        return Element.new(session, el, locator)
      end

      raise ArgumentError, 'Unsupported driver for unified element lookup'
    end

    def self.normalize_locator(locator)
      raise ArgumentError, 'locator must be a Hash' unless locator.is_a?(Hash)
      raise ArgumentError, 'locator cannot be empty' if locator.empty?
      key = locator.keys.first.to_sym
      value = locator.values.first
      [key, value]
    end

    def self.selenium_by_from(key)
      case key
      when :css then :css
      when :xpath then :xpath
      when :id then :id
      when :name then :name
      when :link_text then :link_text
      else
        :css
      end
    end

    def self.playwright_selector_from(key, value)
      case key
      when :css then value
      when :xpath then "xpath=#{value}"
      when :id then "##{value}"
      when :name then "[name='#{value}']"
      else
        value.to_s
      end
    end
  end
end
