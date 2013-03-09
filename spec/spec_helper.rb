require 'rubygems'
require 'bundler/setup'
require 'mocha'
require 'taza'
require 'watir-webdriver'
require 'selenium-webdriver'
require 'generator_spec'
require 'thor'
require 'stringio'
require 'fileutils'

RSpec.configure do |config|
  config.mock_with :mocha
end

def null_device
  File.file?('/dev/null') ? '/dev/null' : 'NUL'
end

# Must set before requiring generator libs.
TMP_ROOT = File.join(File.dirname(__FILE__),"sandbox","generated")
PROJECT_NAME = 'example'
PROJECT_FOLDER = File.join(TMP_ROOT,PROJECT_NAME)
APP_ROOT = File.join(TMP_ROOT, PROJECT_NAME)

Dir[File.expand_path("../..", __FILE__) + "/generators/*/*.rb"].each do |generator|
  require generator
end

module Helpers
  module Generator

    def run(command)
      mkdir_p APP_ROOT
      cd(APP_ROOT) do
        system("#{command}")
      end
    end
    
    def thor(args)
      run("taza #{args}")
    end

    def generate_page(page,site_name)
      thor("page #{page} #{site_name}")
    end

    def generate_site(site_name)
     # site_name = "#{site_name}#{Time.now.to_i}"
      thor("site #{site_name}")
      site_file_path = File.join(PROJECT_FOLDER,'lib','sites',"#{site_name.underscore}.rb")
      require site_file_path
      "::#{site_name.camelize}::#{site_name.camelize}".constantize.any_instance.stubs(:base_path).returns(PROJECT_FOLDER)
      site_name.camelize.constantize
    end
  end

  module Taza
    def stub_settings
      ::Taza::Settings.stubs(:config).returns({})
    end

    def stub_browser
      stub_browser = stub()
      stub_browser.stubs(:goto)
      stub_browser.stubs(:close)
      ::Taza::Browser.stubs(:create).returns(stub_browser)
    end
  end
end

def bare_teardown
    FileUtils.rm_rf TMP_ROOT || APP_ROOT
end

def bare_setup
    FileUtils.mkdir_p(APP_ROOT)
    @stdout = StringIO.new
end

def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

module GeneratorSpec
  module Mathcher 
    class File 
      def exists?
        File.exist?(path)
      end
    end
  end
end
