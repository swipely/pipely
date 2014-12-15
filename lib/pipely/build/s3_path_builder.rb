require 'pathology'

module Pipely
  module Build

    # Builds paths to assets, logs, and steps that are on S3.
    #
    class S3PathBuilder

      START_TIME = "\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}"
      START_DATE = "\#{format(@scheduledStartTime,'YYYY-MM-dd')}"

      # options[:templates] should contain a Hash of your desired S3 path
      # patterns, formatted for Pathology.  The remainder of the options Hash
      # serves as interpolation values for the templates.
      #
      # Several additional interpolation variables (:protocol, :timestamp,
      # :datestamp) are provided by S3PathBuilder at interpolation time.
      #
      # If options[:templates] is not present, or if it is missing any of the
      # legacy templates (assets, logs, steps, etc.), they will be
      # automatically built, using bucket names found in the options Hash,
      # preserving the original behavior.
      #
      def initialize(options)
        @options = options.merge({
          timestamp: START_TIME,
          datestamp: START_DATE,
        })

        @path_templates = default_templates

        if templates = @options.delete(:templates)
          @path_templates.merge!(templates)
        end
      end

      # Support legacy interface, wherein config simply contained bucket names,
      # and users were forced to abide by Pipely's somewhat arbitrary path
      # structure.
      #
      def default_templates
        assets, logs, steps = @options.values_at(:assets, :logs, :steps)

        {
          asset: ":protocol://#{assets}/:prefix/:timestamp",
          log: ":protocol://#{logs}/:prefix/:timestamp",
          step: ":protocol://#{steps}/:prefix",
          shared_asset: ":protocol://#{assets}/:prefix/shared/:datestamp",
          bucket_relative_asset: ':prefix/:timestamp',
        }
      end

      # Implement path interpolation methods, e.g. s3_log_prefix, etc.
      #
      def method_missing(method_name, *args, &block)
        case method_name
        when /^(s3n?)_(.*)_prefix$/
          if pattern = @path_templates[$2.to_sym]
            Pathology.template(pattern).interpolate(
              @options.merge({protocol: $1})
            )
          else
            super
          end
        else
          super
        end
      end

      # Re-route legacy method name to the standard format implemented by
      # method_missing above.
      #
      def bucket_relative_s3_asset_prefix
        s3_bucket_relative_asset_prefix
      end

      def to_hash
        values = %w(s3 s3n).flat_map do |protocol|
          @path_templates.keys.map do |path_name|
            key = "#{protocol}_#{path_name}_prefix".to_sym
            [key, send(key)]
          end
        end

        # Support legacy method name.
        Hash[values].merge({
          bucket_relative_s3_asset_prefix: bucket_relative_s3_asset_prefix
        })
      end

    end

  end
end
