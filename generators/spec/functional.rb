require 'rubygems'
require 'thor'
require 'thor/group'

class IsolationSpec < Thor::Group
  include Thor::Actions
  source_root File.expand_path('../templates', __FILE__)

  argument :name
  argument :site_name
  argument :section, :optional => true

  def verify_site_exists
    unless File.directory?(File.join(destination_root,'lib','sites', site_name.underscore))
      say "******No such site #{site_name} exists.******"
      exit 1
    end
  end

  def functional
    base_spec_path = File.join('spec', 'isolation', "#{site_name}")
    if section.nil?
      spec_path = base_spec_path
    else
      spec_path = File.join("#{base_spec_path}", "#{section}" )
    end
    template('functional_page_spec.tt', "#{spec_path}/#{name.underscore}_page_spec.rb")
  end

end



