require 'pipely/build/definition'
require 'pipely/build/template'
require 'pipely/build/daily_scheduler'
require 'pipely/build/right_now_scheduler'
require 'pipely/build/s3_path_builder'
require 'pipely/build/environment_config'

module Pipely

  # Turn Templates+config into a deployable Definition.
  #
  module Build

    def self.build_definition(template, environment, config_path)
      env = environment.to_sym
      config = EnvironmentConfig.load(config_path, env)

      case environment.to_sym
      when :production
        s3_prefix = "production/#{config[:namespace]}"
        if config[:start_time]
          # allow config to change pipelint start time
          # TODO: all scheduling should be done through config before pipely 1.0
          scheduler = DailyScheduler.new(config[:start_time])
        else
          scheduler = DailyScheduler.new
        end
      when :staging
        s3_prefix = "staging/#{`whoami`.strip}/#{config[:namespace]}"
        scheduler = RightNowScheduler.new
      end

      Definition.new(template, env, s3_prefix, scheduler, config)
    end

  end
end
