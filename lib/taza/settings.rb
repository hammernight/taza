require 'active_support'
require 'taza/options'
require 'uri'

module Taza
  class Settings
    @overrides = Hash.new { |h,k| h[k] = {} }

    class << self
      #   Taza::Settings.config('google')
      def config(site_name)
        site_name = site_name.to_s
        site_file(site_name).merge(Options.new.execute).merge(overrides_for(site_name))
      end

      # Resolve a URL or relative path against a base URL.
      # - If url_or_path is an absolute URL, return as-is.
      # - If relative and base is provided, join and return absolute URL.
      # - If relative and base is nil, return the input string.
      def resolve_url(url_or_path, base: nil)
        return url_or_path if url_or_path.nil?
        s = url_or_path.to_s
        begin
          uri = URI.parse(s)
          return s if uri.is_a?(URI::HTTP) && uri.absolute?
        rescue URI::InvalidURIError
          # fall through
        end
        return s if base.nil? || base.to_s.strip.empty?
        begin
          URI.join(base.to_s, s).to_s
        rescue StandardError
          s
        end
      end

      # Runtime override of site settings (highest precedence)
      def override(site_name, opts = {})
        site = site_name.to_s
        @overrides[site] = @overrides[site].merge(opts || {})
      end

      def clear_overrides!(site_name = nil)
        if site_name
          @overrides.delete(site_name.to_s)
        else
          @overrides.clear
        end
      end

      # Loads the config file for the entire project and returns the hash.
      # Does not override settings from the ENV variables.
      def config_file
        YAML.load_file(config_file_path)
      end

      def config_file_path # :nodoc:
        File.join(config_folder,'config.yml')
      end

      def config_folder # :nodoc:
        File.join(path,'config')
      end

      def site_file(site_name) # :nodoc:
        YAML.load(ERB.new(File.read(File.join(config_folder,"#{site_name.underscore}.yml"))).result)[ENV['TAZA_ENV']]
      end

      def path # :nodoc:
        '.'
      end

      private

      def overrides_for(site_name)
        @overrides[site_name.to_s] || {}
      end
    end
  end
end
