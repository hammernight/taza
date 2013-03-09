require 'spec_helper'
require 'generator_spec/test_case'


describe Flow, "arguments NAME SITE_NAME" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ["CheckOut", "Foo"]

  before :all do 
    bare_setup
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
                    directory "flows" do 
                      file "check_out.rb" do
                        contains "Foo"
                        contains "Foo < ::Taza::Site"
                        contains "def check_out_flow(params={})"
                      end
                    end
                  end
                end
              end
      }
    end
end


describe Flow, "no arguments" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  before :all do 
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


describe Page, "arguments NAME SITE_NAME does not exist" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'BadSite']

  before :all do 
    prepare_destination
  end

  after :all do 
    bare_teardown
  end

  it "exits the process" do 
    lambda { run_generator }.should raise_error SystemExit
  end

end


describe Flow, "should generate a flow" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'Gap']

  before :all do 
    prepare_destination
  end

  after :all do 
    bare_teardown
  end

  it "that the site can access" do
    @site_class = generate_site('Gap')
    run_generator
    stub_settings
    stub_browser
    @site_class.new.check_out_flow
  end
end
