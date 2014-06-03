require_relative '../../spec_helper'
require 'taza/browser'
require 'taza/settings'
require 'taza/options'
require 'selenium'
require 'watir-webdriver'

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

  it "should be able to attach to an open IE instance" do
    browser = Object.new
    Watir::Browser.stubs(:find).returns(browser)
    Watir::Browser.stubs(:new).returns(browser)
    old_browser = Watir::Browser.new
    new_browser = Taza::Browser.create(:browser => :ie, :driver => :watir, :attach => true)
    expect(new_browser).to eql old_browser
  end

  it "should be able to open a new IE instance if there is no instance to attach to" do
    browser = Object.new
    Watir::Browser.stubs(:find).returns(stub_everything)
    Watir::Browser.stubs(:new).returns(browser)
    Taza::Browser.create(:browser => :ie, :driver => :watir)
    expect(browser).to be_truthy
  end

  it "should be able to open a new IE instance if attach not specified" do
    foo = Object.new
    bar = Object.new
    Watir::Browser.stubs(:find).returns(foo)
    Watir::Browser.stubs(:new).returns(bar)
    new_browser = Taza::Browser.create(:browser => :ie, :driver => :watir)
    expect(new_browser).to_not eql foo
  end

end
