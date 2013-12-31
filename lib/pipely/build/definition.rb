module Pipely
  module Build

    # Represent a pipeline definition, built from a Template and some config.
    #
    class Definition < Struct.new(:template,:env,:s3_prefix,:scheduler,:config)
      def pipeline_name
        config[:name]
      end

      def base_filename
        config[:namespace]
      end

      def s3_path_builder
        S3PathBuilder.new(config[:s3].merge(prefix: s3_prefix))
      end

      def to_json
        template.apply_config(:environment => env)
        template.apply_config(config)
        template.apply_config(s3_path_builder.to_hash)
        template.apply_config(scheduler.to_hash)

        template.to_json
      end
    end

  end
end
