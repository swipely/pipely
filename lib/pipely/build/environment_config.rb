require 'yaml'

module Pipely
  module Build

    # Work with YAML config files that contain parallel configs for various
    # environments.
    #
    class EnvironmentConfig < Hash

      # Continue supporting env-based defaults until pipely v1.0
      ENV_DEFAULTS = {
        production: {
          s3_prefix: 'production/:namespace',
          scheduler: 'daily',
          start_time: '11:00:00',
        },
        staging: {
          s3_prefix: 'staging/:whoami/:namespace',
          scheduler: 'now',
        }
      }

      def self.load(filename, environment)
        raw = YAML.load_file(filename)[environment.to_s]
        config = load_from_hash(raw)

        if defaults = ENV_DEFAULTS[environment.to_sym]
          defaults.merge(config)
        else
          config
        end
      end

      def self.load_from_hash(attributes)
        config = new

        attributes.each do |k, v|
          case v
          when Hash
            config[k.to_sym] = load_from_hash(v)
          else
            config[k.to_sym] = v.clone
          end
        end

        config
      end

    end

  end
end
