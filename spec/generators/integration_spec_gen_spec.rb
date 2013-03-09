require 'spec_helper'
require 'rubygems'
require 'fileutils'
require 'taza/page'
require 'generator_spec/test_case'



describe IntegrationSpec, "integration NAME SITES" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ['CheckOut', 'Gap', 'Admin']

  before :all do 
  	bare_setup 
  	prepare_destination 
  	generate_site('Gap')
  	generate_site('Admin')
  	run_generator
  end

  after :each do 
  	bare_teardown
  end

  specify do 
	    destination_root.should have_structure {
	      directory "spec" do 
	          directory "integration" do 
	              file "check_out_spec.rb" do 
                  contains "require 'gap'"
                  contains "require 'admin'"
                end
	          end
	      end
	    }
    end	
end

describe IntegrationSpec, "integration no arguments" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  before :each do 
  	bare_setup
    prepare_destination
    generate_site('Gap')
    generate_site('Admin')
  end

  after :each do 
    bare_teardown
  end

    it "outputs an error message" do 
     output = capture(:stderr) { run_generator }
     output.should include("No value provided for required arguments 'name', 'sites'")
    end
end

describe IntegrationSpec, "integration NAME SITES one site does not exist" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'Gap', 'BadSite']

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