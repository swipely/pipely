module Pipely
  module Build

    # Builds paths to assets, logs, and steps that are on S3.
    #
    class S3PathBuilder

      attr_reader :assets_bucket, :logs_bucket, :steps_bucket

      START_TIME = "\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}"

      def initialize(options)
        @assets_bucket = options[:assets]
        @logs_bucket = options[:logs]
        @steps_bucket = options[:steps]
        @s3prefix = options[:prefix]
      end

      def s3_log_prefix
        "s3://#{@logs_bucket}/#{@s3prefix}/#{START_TIME}"
      end

      def s3_step_prefix
        "s3://#{@steps_bucket}/#{@s3prefix}"
      end

      def s3n_step_prefix
        "s3n://#{@steps_bucket}/#{@s3prefix}"
      end

      def s3_asset_prefix
        "s3://#{@assets_bucket}/#{bucket_relative_s3_asset_prefix}"
      end

      def s3n_asset_prefix
        "s3n://#{@assets_bucket}/#{@s3prefix}/#{START_TIME}"
      end

      def bucket_relative_s3_asset_prefix
        "#{@s3prefix}/#{START_TIME}"
      end

      def to_hash
        {
          :s3_log_prefix => s3_log_prefix,
          :s3_step_prefix => s3_step_prefix,
          :s3n_step_prefix => s3n_step_prefix,
          :s3_asset_prefix => s3_asset_prefix,
          :s3n_asset_prefix => s3n_asset_prefix,
          :bucket_relative_s3_asset_prefix => bucket_relative_s3_asset_prefix,
        }
      end

    end

  end
end
