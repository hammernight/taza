require 'rubygems'
require 'taza'
require 'thor'
require 'thor/group'

class Partial < Thor::Group 
	include Thor::Actions
	source_root File.expand_path('../templates', __FILE__)

	argument :name
	argument :site_name
	
	def verify_site_exists 
		 unless File.directory?(File.join(destination_root,'lib','sites', site_name.underscore))
			say "******No such site #{site_name} exists.******"
			exit 1
		 end
	end

	def create_partial
      partial_path = File.join('lib', 'sites', "#{site_name}", 'pages', 'partials')
      template('partial.tt', "#{partial_path}/#{name.underscore}.rb")
	end

end