require 'spec_helper'
require 'rubygems'
require 'fileutils'
require 'taza/page'
require 'generator_spec/test_case'


describe Page, "arguments NAME SITE_NAME" do
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ['CheckOut', 'Gap']

  before :each do 
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
            directory "#{APP_ROOT}/lib" do 
              directory "sites" do 
                file "#{"Gap".underscore}.rb"
                directory "#{"Gap".underscore}" do 
                  directory "pages" do 
                    file "check_out_page.rb" do 
                      contains "require 'taza/page'"
                    end
                  end
                end
              end
            end
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

describe Page, "arguments NAME SITE_NAME SECTION" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  arguments ['CheckOut', 'Gap', 'cart']

  before :each do 
    prepare_destination
    generate_site('Gap')
    run_generator
  end

  after :each do 
    bare_teardown
  end

  specify do 
    destination_root.should have_structure {
            directory "#{APP_ROOT}/lib" do 
              directory "sites" do 
                file "#{"Gap".underscore}.rb"
                directory "#{"Gap".underscore}" do 
                  directory "pages" do 
                    file "check_out_page.rb" do 
                      contains "require 'taza/page'"
                    end
                  end
                end
              end
            end
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


describe Page, "no arguments" do 
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

describe Page, "arguments NAME SITE_NAME does not exist" do 
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


describe Page, "should generate a page spec" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT

  before :all do 
    bare_teardown
    prepare_destination
  end

    it "that can be required" do 
      @site_class = generate_site('Gap')
      generate_page('CheckOut', 'Gap')
      page_functional_spec = "#{PROJECT_FOLDER}/spec/isolation/#{@site_class.to_s.underscore}/check_out_page_spec.rb"
      system("ruby -c #{page_functional_spec} > #{null_device}").should be_true
    end
end

describe Page, "should generate a page" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'Gap']

  before :all do 
    prepare_destination
  end

  it "that the site can access" do
    @site_class = generate_site('Gap')
    run_generator
    stub_settings
    stub_browser
    @site_class.new.check_out_page
  end
end

describe Page, "should generate a page" do 
  include GeneratorSpec::TestCase
  include Helpers::Generator
  include Helpers::Taza
  destination APP_ROOT
  arguments ['CheckOut', 'Gap']

  before :all do 
    prepare_destination
  end

  it "that can access the generated site file" do
    stub_browser
    stub_settings
    @site_class = generate_site('Gap')
    new_site_class = generate_site('Pag')
    generate_page('CheckOut', 'Gap')
    generate_page('CheckOut', 'Pag')
    new_site_class.new.check_out_page.class.should_not eql(@site_class.new.check_out_page.class)
  end
end

