require 'spec_helper'
require 'rubygems'
require 'fileutils'
require 'taza/page'
require 'generator_spec/test_case'

describe IsolationSpec, "functional NAME SITE_NAME" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ['CheckOut', 'Gap']

  before :all do 
  	bare_setup 
  	prepare_destination 
  	generate_site('Gap')
  	run_generator
  end

  after :each do 
  	bare_teardown
  end

  specify do 
    destination_root.should have_structure {
      directory "spec" do 
          directory "isolation" do 
            directory "#{"Gap".underscore}" do
              file "check_out_page_spec.rb"
            end
          end
      end
    }
  end

end

describe IsolationSpec, "functional NAME SITE_NAME SECTION" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ['CheckOut', 'Gap', 'Cart']

  before :all do 
  	bare_setup 
  	prepare_destination 
  	generate_site('Gap')
  	run_generator
  end

  after :each do 
  	bare_teardown
  end

  specify do 
    destination_root.should have_structure {
      directory "spec" do 
          directory "isolation" do 
	            directory "#{"Gap".underscore}" do
	            	directory "cart" do
	              	file "check_out_page_spec.rb"
	            end
            end
          end
      end
    }
  end	
end

describe IsolationSpec, "functional no arguments" do 
	include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  before :each do 
    prepare_destination
    generate_site('Gap')
  end

  after :each do 
    bare_teardown
  end

    it "outputs an error message" do 
     output = capture(:stderr) { run_generator }
     output.should include("No value provided for required arguments 'name', 'site_name'")
    end
end


describe IsolationSpec, "functional NAME SITE_NAME site does not exist" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'BadSite']

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