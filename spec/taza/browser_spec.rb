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
    @expected_browser.quit unless @expected_browser.nil?
  end

  it 'should use the defaults provided by settings' do
    # skip 'Travis cannot start a real browser'
    @browser = Taza::Browser.create(@settings)
    expect(@browser.name).to eq :chrome
    expect(@browser).to be_an_instance_of Watir::Browser
  end
  
  it 'should use a defined browser' do
    # skip 'Travis cannot start a real browser'
    Taza.define_browser :foo do
      options = Selenium::WebDriver::Chrome::Options.new
      Watir::Browser.new(:chrome, options: options)
    end
    @browser = Taza::Browser.create(@settings.merge(browser: :foo))
    expect(@browser.name).to eql :chrome
    expect(@browser).to be_a Watir::Browser
  end

  it 'should return an error when defined browser uses an unsupported driver' do
    class Unsupported; end
    Taza.define_browser :foo do
      Unsupported.new
    end
    expect(lambda { Taza::Browser.create(browser: :foo) }).to raise_error(Taza::BrowserUnsupportedError)
  end

  it 'should return an error when browser is not defined' do
    expect(lambda { Taza::Browser.create(browser: :bar) }).to raise_error(Taza::BrowserUnsupportedError)
  end

  it 'should provide chrome as a default browser definition' do
    expect(Taza.browsers.keys).to include "chrome"
  end

  it 'should return argument error when using unknown params' do
    Taza.define_browser_with_selenium_webdriver(:chrome, derp: true)
    expect(lambda { Taza::Browser.create(browser: :chrome) }).to raise_error(ArgumentError)
  end

  it 'should define and create a browser instance when the browser is common but undefined' do
    # skip 'Travis cannot start a real browser'
    @browser = Taza::Browser.create(browser: 'firefox')
    expect(@browser.name).to eq :firefox
    expect(@browser).to be_a Watir::Browser
  end

  it 'should return an error when browser is defined with name that is not a common browser' do
    Taza.define_browser_with_selenium_webdriver(:derp)
    expect(lambda { Taza::Browser.create(browser: :derp) }).to raise_error(ArgumentError)
  end
end
