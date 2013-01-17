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
            contains "driver: watir"
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
          file "Gemfile" do
            contains "gem 'watir'"
          end
          file "Rakefile"
        end
      }

    end
  end


  describe New, "argument NAME 'watir-webdriver'" do
    include GeneratorSpec::TestCase
    destination TMP_ROOT

    arguments [PROJECT_NAME, 'watir-webdriver']

    before :all do
      prepare_destination
      run_generator
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
          file "Gemfile" do
            contains "gem 'watir-webdriver'"
          end
          file "Rakefile"
        end
      }
    end
  end





