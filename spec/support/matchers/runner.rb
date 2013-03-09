require "pathname"

module Spec
  module GeneratorRunner
    def taza_root
      Pathname.new(File.expand_path("../../..", __FILE__))
    end

    def root
      taza_root.join("spec/sandbox")
    end

    def sandbox
      root.join("generated/example")
    end

    def clean(path = "")
      FileUtils.rm_rf(root.join(path))
      FileUtils.mkdir_p(root)
    end

    def run(command)
      mkdir_p sandbox
      cd(sandbox) do
        system("#{command}")
      end
    end
  
    def thor(args)
      run("thor #{args}")
    end

    def generate_site(site_name)
     # site_name = "#{site_name}#{Time.now.to_i}"
      thor("site #{site_name}")
      site_file_path = File.join(PROJECT_FOLDER,'lib','sites',"#{site_name.underscore}.rb")
      require site_file_path
      "::#{site_name.camelize}::#{site_name.camelize}".constantize.any_instance.stubs(:base_path).returns(PROJECT_FOLDER)
      site_name.camelize.constantize
    end
  end
end