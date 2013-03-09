require 'rubygems'
require 'taza'
require 'thor'
require 'thor/group'

class Site < Thor::Group 
	include Thor::Actions
	source_root File.expand_path('../templates', __FILE__)

	argument :name
	argument :url, :optional => true, :default => 'www.google.com'

	def check_site_exists 
		 if File.directory?(File.join(destination_root,'lib','sites', name.underscore))
			say "******No such site #{name} exists.******"
			exit 1
		 end
	end

	def create
      site_path = File.join('lib','sites')
      template("site.tt", "#{site_path}/#{name.underscore}.rb")
	  template("site.yml.erb", "config/#{name.underscore}.yml")
	  empty_directory("#{site_path}/#{name.underscore}/flows")
	  empty_directory("#{site_path}/#{name.underscore}/pages")
	  empty_directory("#{site_path}/#{name.underscore}/pages/partials")
	  empty_directory("spec/isolation/#{name.underscore}")
	  empty_directory("spec/support/#{name.underscore}")
	end
end