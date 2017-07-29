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
    expect(lambda { Taza::Browser.create(:browser => :foo_browser_9000,:driver => :watir) }).to raise_error(StandardError)
  end

  it "should use browser param when passing a custom webdriver to watir" do
    skip 'Travis cannot start a real browser'
    options = Selenium::WebDriver::Chrome::Options.new
    driver = Selenium::WebDriver.for(:chrome, options: options)
    Taza::Browser.create(:browser => driver)
  end

  it "should use driver param when creating a browser with selenium webdriver" do
    skip 'Travis cannot start a real browser'
    Taza::Browser.create(:browser => :firefox, :driver => :selenium_webdriver)
  end

  it "should raise an argument error when creating an unknown browser with selenium webdriver" do
    expect(lambda { Taza::Browser.create(:browser => :foo, :driver => :selenium_webdriver) }).to raise_error(ArgumentError)
  end
  
  it "should raise an argument error when creating an unknown browser with watir" do
    expect(lambda { Taza::Browser.create(:browser => :foo, :driver => :watir) }).to raise_error(ArgumentError)
  end

  it "should raise an error when creating a browser with an unknown driver" do
    expect(lambda { Taza::Browser.create(:browser => :firefox, :driver => :foo) }).to raise_error(StandardError)
  end

  it "should use params browser type when creating an watir instance" do
    Watir::Browser.expects(:new).with(:firefox)
    browser = Taza::Browser.create(:browser => :firefox)
  end

  it 'should use params browser type when creating an selenium webdriver instance' do
    Selenium::WebDriver.expects(:for).with(:firefox)
    browser = Taza::Browser.create(browser: :firefox, driver: :selenium_webdriver)
  end
end
