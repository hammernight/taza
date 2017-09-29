require 'user-choices'
module Taza
  class Options < UserChoices::Command
    include UserChoices

    def add_sources(builder)
#     builder.add_source(CommandLineSource, :usage, "Usage: ruby #{$0} [options] file1 [file2]")
      builder.add_source(EnvironmentSource, :mapping, {:browser => 'BROWSER', :driver => 'DRIVER'})
      builder.add_source(YamlConfigFileSource, :from_complete_path, Settings.config_file_path)
    end

    def add_choices(builder)
     builder.add_choice(:browser, :type=>:string, :default=>'chrome')
     builder.add_choice(:driver, :type=>:string, :default=>'watir')
    end

    def execute
      @user_choices
    end
  end
end
