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

  it "should use params browser type when using a custom driver" do
    skip 'Travis cannot start a real browser'
    options = Selenium::WebDriver::Chrome::Options.new
    driver = Selenium::WebDriver.for(:chrome, options: options)
    Taza::Browser.create(:browser => driver)
  end

  it "should raise an argument error when creating an unknown browser" do
    expect(lambda { Taza::Browser.create(:browser => :foo) }).to raise_error(ArgumentError)
  end

  it "should use params browser type when creating an watir webdriver instance" do
    Watir::Browser.expects(:new).with(:firefox)
    browser = Taza::Browser.create(:browser => :firefox)
  end


end
