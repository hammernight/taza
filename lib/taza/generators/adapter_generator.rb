require 'thor'
require 'active_support/all'

module Taza
  class AdapterGenerator < Thor::Group
    include Thor::Actions

    argument :name

    def self.source_root
      File.dirname(__FILE__)
    end

    # Helper methods available to templates
    def adapter_key
      name.underscore
    end

    def class_name
      adapter_key.camelize
    end

    desc "Generate a browser adapter skeleton. Example: taza adapter acme"
    def adapter
      empty_directory 'lib/taza/drivers'
      template('templates/adapter/driver.rb.tt', "lib/taza/drivers/#{adapter_key}.rb")

      empty_directory 'spec/support'
      # Only create shared contract file if it doesn't exist to avoid duplicates
      unless File.exist?('spec/support/shared_adapter_contract.rb')
        template('templates/adapter/shared_adapter_contract.rb.tt', 'spec/support/shared_adapter_contract.rb')
      end

      empty_directory 'spec/taza'
      template('templates/adapter/adapter_spec.rb.tt', "spec/taza/#{adapter_key}_adapter_spec.rb")
    end
  end
end
