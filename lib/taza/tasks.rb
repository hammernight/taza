require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
include Rake::DSL

module Taza
  module Rake
    class Tasks
      attr_accessor :spec_opts

      def initialize
        yield self if block_given?
        define
      end

      def define_spec_task(name,glob_path)
        RSpec::Core::RakeTask.new name do |t|
          # Build base list from glob
          files = Dir.glob(glob_path)

          # Optional: restrict to a specific site (by folder name under spec/*/<site>)
          if ENV['SITE'] && !ENV['SITE'].strip.empty?
            site = ENV['SITE'].strip
            site_globs = [
              File.join('spec', '**', site, '**', '*_spec.rb')
            ]
            site_files = site_globs.flat_map { |g| Dir.glob(g) }
            files = files & site_files unless site_files.empty?
          end

          t.pattern = files

          # Pass through explicit rspec options and tag filtering
          opts = []
          opts << spec_opts if spec_opts
          opts << "--tag #{ENV['TAGS']}" if ENV['TAGS'] && !ENV['TAGS'].strip.empty?
          t.rspec_opts = opts.join(' ').strip
        end
      end

      def define
        namespace :spec do
          Dir.glob('./spec/*/').each do |dir|
            recurse_to_create_rake_tasks(dir)
          end
        end
      end

      def recurse_to_create_rake_tasks(dir)
        basename = File.basename(dir)
        spec_pattern = File.join(dir,"**","*_spec.rb")
        if (not Dir.glob(spec_pattern).empty?)
          define_spec_task(basename,spec_pattern)
          namespace basename do
            Dir.glob(File.join(dir,"*_spec.rb")).each do |spec_file|
              spec_name = File.basename(spec_file,'_spec.rb')
              define_spec_task(spec_name,spec_file)
            end
            Dir.glob(File.join(dir,"*/")).each do |sub_dir|
              recurse_to_create_rake_tasks(sub_dir)
            end
          end
        end
      end

    end
  end
end
