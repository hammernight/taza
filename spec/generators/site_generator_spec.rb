require 'spec_helper'
require 'rubygems'
require 'fileutils'
require 'generator_spec/test_case'

describe Site, "arguments NAME" do
  include GeneratorSpec::TestCase
  include Helpers::Taza
  destination APP_ROOT

    arguments ["WikipediaFoo"]

    before :each do
      bare_setup
      prepare_destination
      run_generator
    end

    after :each do
      bare_teardown
    end

      specify do
          destination_root.should have_structure {
            directory "#{APP_ROOT}/config" do
                file "#{"WikipediaFoo".underscore}.yml" do
                  contains ":url: www.google.com"
              end
            end
            directory "#{APP_ROOT}/lib" do 
              directory "sites" do 
                file "#{"WikipediaFoo".underscore}.rb"
                directory "#{"WikipediaFoo".underscore}" do 
                  directory "flows"
                  directory "pages" do 
                    directory "partials"
                  end
                end
              end
            end
            directory "#{APP_ROOT}/spec" do 
              directory "isolation" do 
                directory "#{"WikipediaFoo".underscore}"
              end
              directory "support" do 
                directory "#{"WikipediaFoo".underscore}"
              end
            end
          }
        end
end


describe Site, "arguments NAME URL" do 
  include GeneratorSpec::TestCase
  include Helpers::Taza
  destination APP_ROOT

    arguments ['BingFoo', 'http://bing.com']

    before :each do
      bare_setup
      prepare_destination
      run_generator
    end

    after :each do
      bare_teardown
    end

      specify do
          destination_root.should have_structure {
            directory "#{APP_ROOT}/config" do
                file "#{"BingFoo".underscore}.yml" do
                  contains ":url: http://bing.com"
              end
            end
            directory "#{APP_ROOT}/lib" do 
              directory "sites" do 
                file "#{"BingFoo".underscore}.rb"
                directory "#{"BingFoo".underscore}" do 
                  directory "flows"
                  directory "pages" do 
                    directory "partials"
                  end
                end
              end
            end
            directory "#{APP_ROOT}/spec" do 
              directory "isolation" do 
                directory "#{"BingFoo".underscore}"
              end
              directory "support" do 
                directory "#{"BingFoo".underscore}"
              end
            end
          }
        end

end

describe Site, "no arguments" do 
  include GeneratorSpec::TestCase
  include Helpers::Taza
  destination APP_ROOT

    it "outputs an error message" do 
     output = capture(:stderr) { run_generator }
     output.should include("No value provided for required arguments 'name'")
    end
end

describe Site, "valid site" do 
  include GeneratorSpec::TestCase
  include Helpers::Taza
  include Helpers::Generator
  destination APP_ROOT

    before :each do
      bare_setup
      prepare_destination
    end

    after :each do
      bare_teardown
    end 
    
    it "generated site that uses the block given in new" do
        @site_class = generate_site("valid#{Time.now.to_i}")
        stub_settings
        stub_browser
        foo = nil
        @site_class.new {|site| foo = site}
        foo.should_not be_nil
        foo.should be_a_kind_of(Taza::Site)
    end

end

describe Site, "existing site" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza

  destination APP_ROOT
  arguments ['GAP']

  before :all do 
    prepare_destination
    generate_site('Gap')
  end

  after :all do 
    bare_teardown
  end
  
  it "exits the process" do 
    lambda { run_generator }.should raise_error SystemExit
  end
  
end
