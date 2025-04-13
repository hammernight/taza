require 'spec_helper'
require 'rubygems'
require 'taza/settings'
require 'taza/options'
require 'taza/site'

describe Taza::Settings do
  #TODO: we need to clean these tests up some lots of repetition and move skeleton project to tmp dir
  before :all do
    @site_name = 'SiteName'
  end

  before :each do
    ENV['TAZA_ENV'] = 'isolation'
    ENV['BROWSER'] = nil
    ENV['DRIVER'] = nil
    ENV['ATTACH'] = nil
  end

  it "should use environment variable for browser settings" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    ENV['BROWSER'] = 'foo'
    expect(Taza::Settings.config(@site_name)[:browser]).to eql 'foo'
  end

  it "should provide default values if no config file or environment settings provided" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    expect(Taza::Settings.config(@site_name)[:driver]).to eql 'selenium'
    expect(Taza::Settings.config(@site_name)[:browser]).to eql 'firefox'
    expect(Taza::Settings.config(@site_name)[:attach]).to eql false
  end

  it "should use environment variable for driver settings" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    ENV['DRIVER'] = 'bar'
    expect(Taza::Settings.config(@site_name)[:driver]).to eql 'bar'
  end

  it "should be able to load the site yml" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    expect(Taza::Settings.config("SiteName")[:url]).to eql 'http://google.com'
  end

  it "should be able to load a alternate site url" do
    ENV['TAZA_ENV'] = 'clown_shoes'
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    expect(Taza::Settings.config("SiteName")[:url]).to eql 'http://clownshoes.com'
  end

  it "should use the config file's variable for browser settings if no environment variable is set" do
    UserChoices::YamlConfigFileSource.any_instance.stubs(:format_specific_reading).returns({'browser' => 'fu'})
    Taza::Settings.stubs(:path).returns("#{@original_directory}//spec/sandbox")
    expect(Taza::Settings.config(@site_name)[:browser]).to eql 'fu'
  end

  it "should use the ENV variables if specfied instead of config files" do
    ENV['BROWSER'] = 'opera'
    UserChoices::YamlConfigFileSource.any_instance.stubs(:format_specific_reading).returns({'browser' => 'fu'})
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    expect(Taza::Settings.config(@site_name)[:browser]).to eql 'opera'
  end

  it "should use the correct config file to set defaults" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    Taza::Settings.stubs(:config_file_path).returns('spec/sandbox/config.yml')
  end

  it "should raise error for a config file that doesnot exist" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox/file_not_exists.yml")
    expect{Taza::Settings.config}.to raise_error(ArgumentError)
  end

  it "should path point at root directory" do
    expect(Taza::Settings.path).to eql '.'
  end

  it "should use the config file's variable for driver settings if no environment variable is set" do
    UserChoices::YamlConfigFileSource.any_instance.stubs(:format_specific_reading).returns({'driver' => 'fun'})
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    expect(Taza::Settings.config(@site_name)[:driver]).to eql 'fun'
  end

  class SiteName < Taza::Site

  end

  it "a site should be able to load its settings" do
    Taza::Settings.stubs(:path).returns("#{@original_directory}/spec/sandbox")
    expect(SiteName.settings[:url]).to eql 'http://google.com'
  end

end
