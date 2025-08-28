require 'spec_helper'

describe 'Playwright event bridging' do
  it 'publishes console, dialog_open, request, and response events' do
    Kernel.stubs(:require).with('playwright').returns(true)

    # Fake emitters to capture handlers
    class FakeEmitter
      attr_reader :handlers
      def initialize
        @handlers = {}
      end
      def on(event, &block)
        @handlers[event] = block
      end
    end

    page = FakeEmitter.new
    context = FakeEmitter.new
    browser = Object.new
    engine = Object.new
    runtime = Object.new

    # Build a fake Playwright API
    ::Object.const_set(:Playwright, Module.new) unless defined?(::Playwright)
    ::Playwright.singleton_class.send(:define_method, :create) { runtime }

    def runtime.chromium; @__engine; end
    runtime.instance_variable_set(:@__engine, engine)

    def engine.launch(headless: true); @__browser; end
    engine.instance_variable_set(:@__browser, browser)

    def browser.new_context; @__context; end
    browser.instance_variable_set(:@__context, context)

    def context.new_page; @__page; end
    context.instance_variable_set(:@__page, page)

    # Load provider and create a session (wires event handlers)
    require 'taza/drivers/playwright'
    session = Taza::Browser.create(driver: :playwright, browser: :chromium)

    received = { console: nil, dialog: nil, request: nil, response: nil }
    sub_console = Taza::Events.subscribe(:console) { |p| received[:console] = p }
    sub_dialog  = Taza::Events.subscribe(:dialog_open) { |p| received[:dialog] = p }
    sub_req     = Taza::Events.subscribe(:request) { |p| received[:request] = p }
    sub_resp    = Taza::Events.subscribe(:response) { |p| received[:response] = p }

    begin
      # Trigger events through captured handlers
      page.handlers[:console].call(:msg)
      page.handlers[:dialog].call(:dlg)
      context.handlers[:request].call(:req)
      context.handlers[:response].call(:res)

      expect(received[:console]).to eql({ session: session, message: :msg })
      expect(received[:dialog]).to eql({ session: session, dialog: :dlg })
      expect(received[:request]).to eql({ session: session, request: :req })
      expect(received[:response]).to eql({ session: session, response: :res })
    ensure
      Taza::Events.unsubscribe(:console, sub_console)
      Taza::Events.unsubscribe(:dialog_open, sub_dialog)
      Taza::Events.unsubscribe(:request, sub_req)
      Taza::Events.unsubscribe(:response, sub_resp)
      Object.send(:remove_const, :Playwright) if Object.const_defined?(:Playwright)
    end
  end
end

