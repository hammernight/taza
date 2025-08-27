require 'spec_helper'

describe Taza::Browser do

  before :each do
    Taza::Settings.stubs(:config_file).returns({})
    ENV['TAZA_ENV'] = 'isolation'
    ENV['SERVER_PORT'] = nil
    ENV['SERVER_IP'] = nil
    ENV['BROWSER'] = nil
    ENV['DRIVER'] = nil
    ENV['TIMEOUT'] = nil
  end

  it "should raise unknown browser error for unsupported watir browsers" do
    expect { Taza::Browser.create(:browser => :foo_browser_9000, :driver => :watir) }.to raise_error(StandardError)
  end

  it "should use params browser type when creating selenium" do
    skip "Travis cant load selenium. :("
    browser_type = :opera
    Selenium::SeleniumDriver.expects(:new).with(anything, anything, '*opera', anything)
    Taza::Browser.create(:browser => browser_type, :driver => :selenium)
  end

  it "should raise selenium unsupported browser error" do
    Taza::Browser.create(:browser => :foo, :driver => :selenium)
  end

  it "should use params browser type when creating an watir webdriver instance" do
    Kernel.stubs(:require).with('watir').returns(true)
    ::Object.const_set(:Watir, Module.new) unless defined?(::Watir)
    ::Watir.const_set(:Browser, Class.new) unless ::Watir.const_defined?(:Browser)
    ::Watir::Browser.expects(:new).with(:firefox)
    browser = Taza::Browser.create(:browser => :firefox, :driver => :watir)
  ensure
    Object.send(:remove_const, :Watir) if Object.const_defined?(:Watir)
  end

  it 'should use params browser type when creating a selenium webdriver instance' do
    Kernel.stubs(:require).with('selenium-webdriver').returns(true)
    ::Object.const_set(:Selenium, Module.new) unless defined?(::Selenium)
    ::Selenium.const_set(:WebDriver, Module.new) unless ::Selenium.const_defined?(:WebDriver)
    ::Selenium::WebDriver.expects(:for).with(:firefox)
    browser = Taza::Browser.create(:browser => :firefox, :driver => :selenium_webdriver)
  ensure
    if Object.const_defined?(:Selenium)
      Selenium.send(:remove_const, :WebDriver) if Selenium.const_defined?(:WebDriver)
      Object.send(:remove_const, :Selenium)
    end
  end

  it "should be able to create a selenium instance" do
    Kernel.stubs(:require).with('selenium').returns(true)
    ::Object.const_set(:Selenium, Module.new) unless defined?(::Selenium)
    ::Selenium.const_set(:SeleniumDriver, Class.new do
      def initialize(*args); end
    end) unless ::Selenium.const_defined?(:SeleniumDriver)

    Kernel.expects(:warn).with(regexp_matches(/DEPRECATION.*Selenium RC/i))
    browser = Taza::Browser.create(:browser => :firefox, :driver => :selenium)
    expect(browser).to be_a_kind_of Selenium::SeleniumDriver
  ensure
    if Object.const_defined?(:Selenium)
      Selenium.send(:remove_const, :SeleniumDriver) if Selenium.const_defined?(:SeleniumDriver)
      Object.send(:remove_const, :Selenium)
    end
  end

  it "should use environment settings for server port and ip" do
    Kernel.stubs(:require).with('selenium').returns(true)
    ::Object.const_set(:Selenium, Module.new) unless defined?(::Selenium)
    ::Selenium.const_set(:SeleniumDriver, Class.new do
      def initialize(*args); end
    end) unless ::Selenium.const_defined?(:SeleniumDriver)

    # TODO:we need to make this more dynamic and move the skeleton project to the temp dir
    Taza::Settings.stubs(:path).returns(File.join(@original_directory, 'spec', 'sandbox'))
    ENV['SERVER_PORT'] = 'server_port'
    ENV['SERVER_IP'] = 'server_ip'
    Kernel.expects(:warn).with(regexp_matches(/DEPRECATION.*Selenium RC/i))
    Selenium::SeleniumDriver.expects(:new).with('server_ip', 'server_port', anything, anything)
    Taza::Browser.create(
      Taza::Settings.config("SiteName"))
  ensure
    if Object.const_defined?(:Selenium)
      Selenium.send(:remove_const, :SeleniumDriver) if Selenium.const_defined?(:SeleniumDriver)
      Object.send(:remove_const, :Selenium)
    end
  end

  it "should use environment settings for timeout" do
    Kernel.stubs(:require).with('selenium').returns(true)
    ::Object.const_set(:Selenium, Module.new) unless defined?(::Selenium)
    ::Selenium.const_set(:SeleniumDriver, Class.new do
      def initialize(*args); end
    end) unless ::Selenium.const_defined?(:SeleniumDriver)

    Taza::Settings.stubs(:path).returns(File.join(@original_directory, 'spec', 'sandbox'))
    ENV['TIMEOUT'] = 'timeout'
    Kernel.expects(:warn).with(regexp_matches(/DEPRECATION.*Selenium RC/i))
    Selenium::SeleniumDriver.expects(:new).with(anything, anything, anything, 'timeout')
    Taza::Browser.create(Taza::Settings.config("SiteName"))
  ensure
    if Object.const_defined?(:Selenium)
      Selenium.send(:remove_const, :SeleniumDriver) if Selenium.const_defined?(:SeleniumDriver)
      Object.send(:remove_const, :Selenium)
    end
  end

  it "should be able to give you the class of browser" do
    Taza::Browser.expects(:watir_safari).returns(Object)
    expect(Taza::Browser.browser_class(:browser => :safari, :driver => :watir)).to eql Object
  end

end
