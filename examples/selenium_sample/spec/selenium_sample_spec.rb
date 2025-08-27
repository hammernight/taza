require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe 'Selenium WebDriver + Taza (example)', :integration do
  it 'creates a session and finds an element via unified API' do
    # Make the example robust on CI by avoiding launching a real browser.
    # We stub selenium-webdriver when running in CI to keep this smoke test hermetic.
    options = nil
    user_data_dir = nil
    if ENV['CI']
      allow(Kernel).to receive(:require).with('selenium-webdriver').and_return(true)
      # Minimal Selenium shim
      module ::Selenium; end unless defined?(::Selenium)
      module ::Selenium::WebDriver; end unless defined?(::Selenium::WebDriver)

      class FakeNavigation
        attr_reader :last_url
        def to(url); @last_url = url; end
      end
      class FakeRaw
        def navigate; @nav ||= FakeNavigation.new; end
        def find_element(_by, _value)
          FakeElement.new
        end
        def quit; end
      end
      class FakeElement
        def displayed?; true; end
        def click; end
        def send_keys(_val); end
        def clear; end
      end

      # Intercept any browser and any args to ensure no real session is created in CI.
      allow(::Selenium::WebDriver).to receive(:for).and_return(FakeRaw.new)
    else
      # For local runs, avoid reusing any existing Chrome profile by creating a unique user data dir.
      require 'selenium-webdriver'
      user_data_dir = Dir.mktmpdir('taza-chrome-profile-')
      options = ::Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-data-dir=#{user_data_dir}")
      # Optional hardening for local flake reduction
      options.add_argument('--no-first-run')
      options.add_argument('--no-default-browser-check')
    end

    session = Taza::Browser.create(driver: :selenium_webdriver, browser: :chrome, options: options)
    begin
      session.goto('https://rieken-portfolio.netlify.app/')
      el = Taza::Elements.find(session, css: 'body')
      expect(el).to be_a(Taza::Elements::Element)
      expect(el.visible?).to be(true)
    ensure
      session.close
      if user_data_dir && Dir.exist?(user_data_dir)
        FileUtils.remove_entry_secure(user_data_dir) rescue nil
      end
    end
  end
end
