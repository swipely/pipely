require 'pipely/build/definition'
require 'pipely/build/template'
require 'pipely/build/daily_scheduler'
require 'pipely/build/hourly_scheduler'
require 'pipely/build/right_now_scheduler'
require 'pipely/build/s3_path_builder'
require 'pipely/build/environment_config'
require 'pathology'

module Pipely

  # Turn Templates+config into a deployable Definition.
  #
  module Build

    def self.build_definition(template, environment, config_path)
      env = environment.to_sym
      config = EnvironmentConfig.load(config_path, env)

      Definition.new(template, env, config)
    end

  end
end
