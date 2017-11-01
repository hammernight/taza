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

  it 'should create a user-defined browser' do
    skip 'Travis cannot start a real browser'
    Taza.define_browser :foo do
      options = Selenium::WebDriver::Chrome::Options.new
      Watir::Browser.new(:chrome, options: options)
    end
    @browser = Taza::Browser.create(:foo)
    expect(@browser.name).to eql :chrome
    expect(@browser).to be_a Watir::Browser
  end

  it 'should create a common browser when none are defined' do
    skip 'Travis cannot start a real browser'
    @browser = Taza::Browser.create(:firefox)
    expect(@browser.name).to eq :firefox
    expect(@browser).to be_a Watir::Browser
  end
  
  it 'should create a user-defined chrome browser with watir' do
    skip 'Travis cannot start a real browser'
    Taza.define_browser_with_watir :chrome, headless: true
    @browser = Taza::Browser.create(:chrome)
    expect(@browser.name).to eq :chrome
    expect(@browser).to be_a Watir::Browser
  end
  
  it 'should create a user-defined chrome browser with watir and a custom name' do
    skip 'Travis cannot start a real browser'
    Taza.define_browser_with_watir :foo, browser: :chrome, headless: true
    @browser = Taza::Browser.create(:foo)
    expect(@browser.name).to eq :chrome
    expect(@browser).to be_a Watir::Browser
  end

  # it 'should return an error when browser param is not set' do
  #   expect(lambda { Taza::Browser.create('chrome') }).to raise_error(Taza::BrowserArgumentError)
  # end

  it 'should return an error when browser is defined with an unsupported driver' do
    class Unsupported; end
    Taza.define_browser :foo do
      Unsupported.new
    end
    expect(lambda { Taza::Browser.create(:foo) }).to raise_error(Taza::BrowserUnsupportedError)
  end

  it 'should return an error when browser is both uncommon and undefined' do
    expect(lambda { Taza::Browser.create(:bar) }).to raise_error(Taza::BrowserNotDefinedError)
  end

  it 'should return argument error when using unknown params with selenium webdriver' do
    Taza.define_browser_with_selenium_webdriver(:chrome, derp: true)
    expect(lambda { Taza::Browser.create(:chrome) }).to raise_error(ArgumentError)
  end
  
  it 'should return an error when browser is defined with name that is not a common browser' do
    Taza.define_browser_with_selenium_webdriver(:derp)
    expect(lambda { Taza::Browser.create(:derp) }).to raise_error(ArgumentError)
  end
end
