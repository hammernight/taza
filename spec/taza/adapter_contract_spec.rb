require 'spec_helper'

describe 'Built-in providers adapter contract' do
  describe 'watir provider' do
    it 'wraps Watir::Browser and delegates goto/close' do
      # Avoid loading the real gem
      Kernel.stubs(:require).with('watir').returns(true)

      raw = mock('watir-browser')
      ::Object.const_set(:Watir, Module.new) unless defined?(::Watir)
      ::Watir.const_set(:Browser, Class.new) unless ::Watir.const_defined?(:Browser)
      ::Watir::Browser.expects(:new).with(:firefox).returns(raw)

      session = Taza::Browser.create(driver: :watir, browser: :firefox)
      expect(session).to be_a(Taza::Browser::Session)

      raw.expects(:goto).with(TEST_URL)
      session.goto(TEST_URL)

      raw.expects(:close)
      session.close
    ensure
      Object.send(:remove_const, :Watir) if Object.const_defined?(:Watir)
    end
  end

  describe 'selenium_webdriver provider' do
    it 'wraps Selenium::WebDriver and delegates navigate.to/quit' do
      Kernel.stubs(:require).with('selenium-webdriver').returns(true)

      raw = mock('selenium-driver')
      nav = mock('navigation')

      ::Object.const_set(:Selenium, Module.new) unless defined?(::Selenium)
      ::Selenium.const_set(:WebDriver, Module.new) unless ::Selenium.const_defined?(:WebDriver)
      ::Selenium::WebDriver.expects(:for).with(:chrome).returns(raw)

      raw.expects(:navigate).returns(nav)
      nav.expects(:to).with(TEST_URL)

      session = Taza::Browser.create(driver: :selenium_webdriver, browser: :chrome)
      expect(session).to be_a(Taza::Browser::Session)

      session.goto(TEST_URL)

      raw.expects(:quit)
      session.close
    ensure
      if Object.const_defined?(:Selenium)
        Selenium.send(:remove_const, :WebDriver) if Selenium.const_defined?(:WebDriver)
        Object.send(:remove_const, :Selenium)
      end
    end

    it 'forwards options to Selenium::WebDriver.for when provided' do
      Kernel.stubs(:require).with('selenium-webdriver').returns(true)

      raw = mock('selenium-driver')
      ::Object.const_set(:Selenium, Module.new) unless defined?(::Selenium)
      ::Selenium.const_set(:WebDriver, Module.new) unless ::Selenium.const_defined?(:WebDriver)

      chrome_options = stub('chrome-options')

      ::Selenium::WebDriver.expects(:for).with do |browser_sym, opts|
        browser_sym == :chrome && opts.is_a?(Hash) && opts[:options] == chrome_options
      end.returns(raw)

      session = Taza::Browser.create(driver: :selenium_webdriver, browser: :chrome, options: chrome_options)
      expect(session).to be_a(Taza::Browser::Session)

      raw.expects(:quit)
      session.close
    ensure
      if Object.const_defined?(:Selenium)
        Selenium.send(:remove_const, :WebDriver) if Selenium.const_defined?(:WebDriver)
        Object.send(:remove_const, :Selenium)
      end
    end
  end
end
