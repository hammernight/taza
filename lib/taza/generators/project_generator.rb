require 'thor'
require 'active_support/all'

module Taza
  class ProjectGenerator < Thor::Group
    include Thor::Actions

    argument :site_name
    argument :browser, :default => 'firefox'

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "This creates the Taza project structure. Example taza create foo"
    def create
      template('templates/project/Gemfile.tt', 'Gemfile') unless File.exists? 'Gemfile'
      template('templates/project/Rakefile.tt', 'Rakefile') unless File.exists? 'Rakefile'
      template('templates/project/config.yml.tt', 'config/config.yml') unless File.exists? 'config/config.yml'
      empty_directory 'lib/sites'
      empty_directory 'spec'
      template('templates/project/spec_helper.rb.tt', 'spec/spec_helper.rb') unless File.exists? 'spec/spec_helper.rb'
      empty_directory 'spec/isolation'
      empty_directory 'spec/integration'
      empty_directory 'bin'
      template('templates/project/taza.tt', 'bin/taza') unless File.exists? 'bin/taza'
    end
  end
end