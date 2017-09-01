require 'spec_helper'

describe Taza::Browser do

  before :each do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    ENV['TAZA_ENV'] = 'isolation'
    @settings = Taza::Settings.config('SiteName')
    @browser = nil
  end

  after :each do
    @browser.quit unless @browser.nil?
  end

  it 'should use the defaults provided by settings' do
    skip 'Travis cannot start a real browser'
    @browser = Taza::Browser.create(@settings)
    expect(@browser.name).to eq :firefox
    expect(@browser).to be_an_instance_of Watir::Browser
  end
  
  it 'should use a defined browser' do
    skip 'Travis cannot start a real browser'
    Taza.define_browser :foo do
      options = Selenium::WebDriver::Chrome::Options.new
      Watir::Browser.new(:chrome, options: options)
    end
    @browser = Taza::Browser.create(@settings.merge(browser: :foo))
    expect(@browser.name).to eql :chrome
    expect(@browser).to be_a Watir::Browser
  end

  it 'should use use a defined browser without watir' do
    skip 'Travis cannot start a real browser'
    Taza.define_browser :foo do
      Selenium::WebDriver.for(:chrome)
    end
    @browser = Taza::Browser.create(browser: :foo)
    expect(@browser.browser).to eql :chrome
    expect(@browser).to be_a Selenium::WebDriver::Driver
  end

  it 'should return an error when defined browser is not using supported drivers' do
    class Unsupported; end
    Taza.define_browser :foo do
      Unsupported.new
    end
    expect(lambda { Taza::Browser.create(browser: :foo) }).to raise_error(Taza::BrowserUnsupportedError)
  end

  it 'should return an error when browser is not defined' do
    expect(lambda { Taza::Browser.create(browser: :bar) }).to raise_error(Taza::BrowserUnknownError)
  end

  it 'should provide a set of default browsers' do
    expect(Taza.browsers.keys).to include "chrome", "firefox", "ie", "phantomjs"
  end
end
