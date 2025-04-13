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
    Watir::Browser.expects(:new).with(:firefox)
    browser = Taza::Browser.create(:browser => :firefox, :driver => :watir)
  end

  it 'should use params browser type when creating a selenium webdriver instance' do
    Selenium::WebDriver.expects(:for).with(:firefox)
    browser = Taza::Browser.create(:browser => :firefox, :driver => :selenium_webdriver)
  end

  it "should be able to create a selenium instance" do
    browser = Taza::Browser.create(:browser => :firefox, :driver => :selenium)
    expect(browser).to be_a_kind_of Selenium::SeleniumDriver
  end

  it "should use environment settings for server port and ip" do
    # TODO:we need to make this more dynamic and move the skeleton project to the temp dir
    Taza::Settings.stubs(:path).returns(File.join(@original_directory, 'spec', 'sandbox'))
    ENV['SERVER_PORT'] = 'server_port'
    ENV['SERVER_IP'] = 'server_ip'
    Selenium::SeleniumDriver.expects(:new).with('server_ip', 'server_port', anything, anything)
    Taza::Browser.create(
      Taza::Settings.config("SiteName"))
  end

  it "should use environment settings for timeout" do
    Taza::Settings.stubs(:path).returns(File.join(@original_directory, 'spec', 'sandbox'))
    ENV['TIMEOUT'] = 'timeout'
    Selenium::SeleniumDriver.expects(:new).with(anything, anything, anything, 'timeout')
    Taza::Browser.create(Taza::Settings.config("SiteName"))
  end

  it "should be able to give you the class of browser" do
    Taza::Browser.expects(:watir_safari).returns(Object)
    expect(Taza::Browser.browser_class(:browser => :safari, :driver => :watir)).to eql Object
  end

end
