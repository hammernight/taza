require 'rubygems'
require 'thor'
require 'thor/group'

class Models < Thor
     include Thor::Actions
     source_root File.expand_path('../templates', __FILE__)

     desc "config SITE_NAME", "setup the sequel orm."
     def config(site_name) 
          @site_name = site_name
          support_path = File.join('spec', 'support', "#{site_name}")
          if File.exists?(support_path)
               db_path = File.join("#{support_path}", "DB")
               template("config.tt", "#{db_path}/env.rb")
               append_file('Gemfile', "\ngem 'sequel'", :verbose => false)
          end
     end

     desc "new MODEL_NAME SITE_NAME TABLE_NAME", "Generates a model."
     def new(model_name, site_name, table_name=nil)
          @model_name = model_name 
          @site_name = site_name
          @table_name = table_name
         db_path = File.join('spec', 'support', "#{site_name}", "DB")
         template("model.tt", "#{db_path}/#{model_name}.rb")
   
     end
end