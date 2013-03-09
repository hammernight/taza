require 'spec_helper'
require 'rubygems'
require 'rake'
require 'fileutils'
require 'generator_spec/test_case'




  describe New, "with the default driver" do
    include GeneratorSpec::TestCase
    destination TMP_ROOT

    arguments [PROJECT_NAME]

    before :all do
      prepare_destination
      run_generator
    end

    after do
      bare_teardown
    end

    specify do
      destination_root.should have_structure {
        directory "#{PROJECT_NAME}/config" do
          file "config.yml" do
            contains "driver: watir_webdriver"
            contains "browser: firefox"
          end
        end
        directory "#{PROJECT_NAME}/lib" do
          directory "sites"
        end
        directory "#{PROJECT_NAME}/spec" do
          directory "integration"
          directory "isolation"
          directory "story"
          directory "support"
          file "spec_helper.rb"
        end
        directory "#{PROJECT_NAME}" do
          file "Gemfile"
          file "Rakefile"
        end
      }

    end
  end


  describe New, "argument NAME 'selenium-webdriver'" do
    include GeneratorSpec::TestCase
    destination TMP_ROOT

    arguments [PROJECT_NAME, 'selenium-webdriver']

    before :all do
      prepare_destination
      run_generator
    end

    after do
      bare_teardown
    end

    specify do
      destination_root.should have_structure {
        directory "#{PROJECT_NAME}/config" do
          file "config.yml" do
            contains "driver: selenium_webdriver"
            contains "browser: firefox"
          end
        end
        directory "#{PROJECT_NAME}/lib" do
          directory "sites"
        end
        directory "#{PROJECT_NAME}/spec" do
          directory "integration"
          directory "isolation"
          directory "story"
          directory "support"
          file "spec_helper.rb"
        end
        directory "#{PROJECT_NAME}" do
          file "Gemfile"
          file "Rakefile"
        end
      }
    end
  end


  describe New, "argument NAME DRIVER BROWSER" do
    include GeneratorSpec::TestCase
    destination TMP_ROOT

    arguments [PROJECT_NAME, 'watir-webdriver', 'ie']

    before :all do
      prepare_destination
      run_generator
    end

    after do
      bare_teardown
    end

    specify do
      destination_root.should have_structure {
        directory "#{PROJECT_NAME}/config" do
          file "config.yml" do
            contains "driver: watir_webdriver"
            contains "browser: ie"
          end
        end
        directory "#{PROJECT_NAME}/lib" do
          directory "sites"
        end
        directory "#{PROJECT_NAME}/spec" do
          directory "integration"
          directory "isolation"
          directory "story"
          directory "support"
          file "spec_helper.rb"
        end
        directory "#{PROJECT_NAME}" do
          file "Gemfile"
          file "Rakefile"
        end
      }
    end
  end





