require 'rubygems'
require 'taza'
require 'thor'
require 'thor/group'

class New < Thor::Group
     include Thor::Actions
     source_root File.expand_path('../templates', __FILE__)

     argument :name
     argument :driver, :default => 'watir-webdriver', :optional => true
     argument :browser, :default => 'firefox', :optional => true

     def create_config_file
     	template('config.tt', "#{name}/config/config.yml")
     end

     def create_lib_folder
     	empty_directory("#{name}/lib/sites")
     end

     def create_spec_folder
     	template("spec_helper.tt", "#{name}/spec/spec_helper.rb")
     	empty_directory("#{name}/spec/isolation")
     	empty_directory("#{name}/spec/integration")
     	empty_directory("#{name}/spec/story")
     	empty_directory("#{name}/spec/support")
     end

     def create_rakefile 
     	template("rakefile.tt", "#{name}/Rakefile")
     end

     def create_gemfile
     	template("Gemfile.tt", "#{name}/Gemfile")
     #	gem "#{driver}"
     #	#run 'bundle install'
     end

end