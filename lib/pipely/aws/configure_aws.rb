require 'aws-sdk'

module Pipely

  # Use AWS SDK to get information about a pipeline
  module ConfigureAws

    class PipelyConfigNotFound < StandardError; end

    def configure
      config = load_config

      AWS.config(
        access_key_id: config[:access_key_id],
        secret_access_key: config[:secret_access_key],
        region: config[:region]
      )
    end

    private
    def load_config
      path = File.expand_path('~/.pipely')

      if File.exist?(path) && data = File.open(path)
        YAML.load(data)
      else
        raise PipelyConfigNotFound,
          'Need a .pipely file in home directory'
      end
    end

  end

end
