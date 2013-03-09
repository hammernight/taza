require 'rubygems'
require 'taza'
require 'thor'
require 'thor/group'

class Flow < Thor::Group 
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
	

	def create_flow
      flow_path = File.join('lib', 'sites', "#{site_name}", 'flows')
      puts "#{flow_path}"
      template('flow.tt', "#{flow_path}/#{name.underscore}.rb")
	end

end