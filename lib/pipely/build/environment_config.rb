require 'yaml'

module Pipely
  module Build

    # Work with YAML config files that contain parallel configs for various
    # environments.
    #
    class EnvironmentConfig < Hash

      def self.load(filename, environment)
        raw = YAML.load_file(filename)[environment.to_s]
        load_from_hash(raw)
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
