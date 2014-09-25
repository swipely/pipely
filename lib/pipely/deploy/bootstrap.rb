require 'pipely/bundler'
require 'pipely/deploy/bootstrap_context'
require 'pipely/deploy/s3_uploader'

module Pipely
  module Deploy

    # Helps bootstrap a pipeline
    class Bootstrap

      attr_reader :project_spec
      attr_reader :gem_files

      def initialize(s3_uploader)
        @s3_uploader = s3_uploader
      end

      # Builds the project's gem from gemspec, uploads the gem to s3, and
      # uploads all the gem dependences to S3
      def build_and_upload_gems
        @gem_files = Pipely::Bundler.gem_files
        @s3_uploader.upload(@gem_files.values)
      end

      def context(s3_steps_path)
        BootstrapContext.new.tap do |context|
          context.gem_files = @s3_uploader.s3_urls(gem_files.values)
          context.s3_steps_path = s3_steps_path
        end
      end

    end

  end
end
