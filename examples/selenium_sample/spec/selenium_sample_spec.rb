require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe 'Selenium WebDriver + Taza (example)', :integration do
  it 'creates a session and finds an element via unified API' do
    user_data_dir = nil
    options = nil

    if ENV['CI']
      # In CI, stub Selenium so no real browser is launched (parallel-safe and hermetic)
      allow(Kernel).to receive(:require).with('selenium-webdriver').and_return(true)
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

      allow(::Selenium::WebDriver).to receive(:for).and_return(FakeRaw.new)
    else
      require 'selenium-webdriver'
      # Create a unique Chrome profile dir per test run to avoid profile locks.
      user_data_dir = Dir.mktmpdir('taza-chrome-profile-')
      options = ::Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-data-dir=#{user_data_dir}")
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
