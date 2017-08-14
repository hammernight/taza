require 'active_support/all'
require 'taza/version'
require 'taza/page'
require 'taza/site'
require 'taza/browser'
require 'taza/settings'
require 'taza/flow'
require 'taza/entity'
require 'taza/fixtures'
require 'extensions/object'
require 'extensions/string'
require 'extensions/hash'
require 'formatters/failing_examples_formatter'

#generators
require_relative 'taza/generators/project_generator'
require_relative 'taza/generators/site_generator'
require_relative 'taza/generators/page_generator'
require_relative 'taza/generators/partial_generator'
require_relative 'taza/generators/flow_generator'

module ForwardInitialization
  module ClassMethods
    def new(*args,&block)
      const_get("#{name.split("::").last}").new(*args,&block)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end
end
