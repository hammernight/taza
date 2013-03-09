require 'spec_helper'
require 'generator_spec/test_case'


describe Partial, "arguments NAME SITE_NAME" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ["NavBar", "Foo"]

  before :all do 
    bare_setup
    prepare_destination
    generate_site("Foo")
    run_generator
  end

  after :all do 
    bare_teardown
  end

  specify do 
      destination_root.should have_structure {
              directory "#{APP_ROOT}/lib" do 
                directory "sites" do 
                  directory "#{"Foo".underscore}" do 
                    directory "pages" do 
                      directory "partials" do 
                        file "nav_bar.rb" do 
                          contains "module Foo"
                          contains "class NavBar < ::Taza::Page"
                        end
                      end
                    end
                  end
                end
              end
      }
    end
end


describe Partial, "no arguments" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  before :all do 
    prepare_destination
    bare_setup
    generate_site("Foo")
    run_generator
  end

  after :all do 
    bare_teardown
  end

  it "should output an error" do 
     output = capture(:stderr) { run_generator }
     output.should include("No value provided for required arguments 'name', 'site_name'")
  end
end


describe Partial, "arguments NAME SITE_NAME does not exist" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['NavBar', 'BadSite']

  before :all do 
    prepare_destination
    bare_setup
  end

  after :all do 
    bare_teardown
  end

  it "exits the process" do 
    lambda { run_generator }.should raise_error SystemExit
  end

end


describe Partial, "should generate a partial" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'Gap']

  before :all do 
    prepare_destination
    bare_setup
  end

  it "that the site can access" do
    @site_class = generate_site('Gap')
    run_generator
    stub_settings
    stub_browser
    @site_class.new.check_out
  end
end
