require 'spec_helper'

describe 'Playwright provider' do
  it 'builds a Session and wires page navigation and close lifecycle' do
    # Stub Kernel.require to allow provider to require 'playwright'
    Kernel.stubs(:require).with('playwright').returns(true)

    # Build a fake Playwright API surface
    page = mock('page')
    context = mock('context')
    browser = mock('browser')
    engine = mock('engine')
    playwright_runtime = mock('playwright_runtime')

    # Expectations for building the page
    ::Object.const_set(:Playwright, Module.new) unless defined?(::Playwright)
    ::Playwright.singleton_class.send(:define_method, :create) { playwright_runtime }

    playwright_runtime.expects(:chromium).returns(engine)
    engine.expects(:launch).with(has_key(:headless)).returns(browser)
    browser.expects(:new_context).returns(context)
    context.expects(:new_page).returns(page)

    # Load provider and create a session
    require 'taza/drivers/playwright'
    session = Taza::Browser.create(driver: :playwright, browser: :chromium)
    expect(session).to be_a(Taza::Browser::Session)

    # Navigation delegates to page.goto
    page.expects(:goto).with(TEST_URL)
    session.goto(TEST_URL)

    # Closing tears down in order: context, browser, playwright.stop
    context.expects(:close)
    browser.expects(:close)
    playwright_runtime.expects(:stop)
    session.close
  ensure
    # Clean up the stubbed constant to avoid cross-test leakage
    Object.send(:remove_const, :Playwright) if Object.const_defined?(:Playwright)
  end
end
