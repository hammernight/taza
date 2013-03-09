require 'rubygems'
require 'thor'
require 'thor/group'


class IntegrationSpec < Thor::Group
  include Thor::Actions
  source_root File.expand_path('../templates', __FILE__)

  argument :name
  argument :sites, :type => :array

  def verify_site_exists
    sites.each do |site_name|
      unless File.directory?(File.join(destination_root,'lib','sites', site_name.underscore))
        say "******No such site #{site_name} exists.******"
        exit 1
      end
    end
  end

  def integration
    spec_path = File.join('spec', 'integration')
    template('integration_spec.tt', "#{spec_path}/#{name.underscore}_spec.rb")
  end
end