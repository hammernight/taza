require 'taza/fixture'

module Taza
  module Fixtures; end

  # Clean all fixtures previously defined
  def self.clean_fixtures
    remove_const :Fixtures
    const_set :Fixtures, Module.new
  end

  # Load fixtures from a specific path (defaults to Taza::Fixture.base_path)
  #
  # This allows programatically loading your fixtures (i.e. inside spec_helper)
  # if you have multiple fixtures directories (i.e. multiple projects
  # contributing fixtures to your test infrastructure)
  def self.load_fixtures(base_path=nil)
    base_path ||= Fixture.base_path

    dirs = Dir.glob(File.join(base_path, '**', '*')).select {|f| File.directory? f}
    dirs.unshift base_path

    dirs.each do |dir|
      mod = dir.sub(base_path, File.join(File.basename(base_path),'')).sub('//', '/').camelize.sub(/::$/,'')

      # recursively creates the modules the lazy way
      self.class_eval <<-EOS
        module #{mod}; end
      EOS

      helpers_module = "#{self.name}::#{mod}".constantize
      self.append_helper_creation_methods_to helpers_module

      helpers_module.add_fixtures_dir dir

      def helpers_module.included(other_module)
        self.create_fixture_helpers!
      end
    end

  end

  private
    def self.append_helper_creation_methods_to(helpers_module) # :nodoc
      return if helpers_module.respond_to? :create_fixture_helpers!

      class << helpers_module
        def add_fixtures_dir(dir) # :nodoc
          @fixtures_dir ||= []
          @fixtures_dir << dir unless @fixtures_dir.include? dir
        end

        def create_fixture_helpers! # :nodoc
          @loaded_fixture_from_dir ||= {}
          @fixtures_dir.each do |dir|
            return if @loaded_fixture_from_dir[dir]
            @loaded_fixture_from_dir[dir] = true

            fixture = Fixture.new
            fixture.load_fixtures_from(dir)
            fixture.fixture_names.each do |fixture_name|
              define_method(fixture_name) do |entity_key|
                fixture.get_fixture_entity(fixture_name, entity_key.to_s)
              end
            end
          end
        end
      end
    end

end
