module Pipely
  module Build

    # Represent a pipeline definition, built from a Template and some config.
    #
    class Definition < Struct.new(:template, :env, :config)
      def pipeline_name
        config[:name]
      end

      def base_filename
        config[:namespace]
      end

      def s3_path_builder
        if config[:s3_prefix]
          template = Pathology.template(config[:s3_prefix])

          s3_prefix = template.interpolate(interpolation_context)

          S3PathBuilder.new(
            config[:s3].merge(
              prefix: s3_prefix,
              namespace: config[:namespace],
            )
          )
        else
          fail('unspecified s3_prefix')
        end
      end

      def to_json
        template.apply_config(:environment => env)
        template.apply_config(config)
        template.apply_config(s3_path_builder.to_hash)
        template.apply_config(scheduler.to_hash)

        template.to_json
      end

      def scheduler
        case config[:scheduler]
        when 'daily'
          DailyScheduler.new(config[:start_time])
        when 'now'
          RightNowScheduler.new
        else
          fail('unspecified scheduler')
        end
      end

    private

      def interpolation_context
        config.merge({
          :whoami => `whoami`.strip,
        })
      end

    end
  end
end
