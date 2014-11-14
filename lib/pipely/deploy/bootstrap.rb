require 'pipely/bundler'
require 'pipely/deploy/bootstrap_context'
require 'pipely/deploy/s3_uploader'
require 'active_support/core_ext/string/conversions'

module Pipely
  module Deploy

    # Helps bootstrap a pipeline
    class Bootstrap

      attr_reader :gem_files, :s3_steps_path

      def initialize(gem_files, s3_steps_path)
        @gem_files = gem_files
        @s3_steps_path = s3_steps_path
      end

      def context(mixins = [])
        mixins = [mixins].flatten.compact

        mixins.each do |mixin|
          begin
            require mixin.underscore
          rescue LoadError => e
            raise "Failed to require #{mixin} for bootstrap_contexts: #{e}"
          end
        end

        BootstrapContext.class_eval do
          mixins.each do |mixin|
            puts "Adding bootstrap context #{mixin}"
            include mixin.constantize
          end
          self
        end.new.tap do |context|
          context.gem_files = gem_files
          context.s3_steps_path = s3_steps_path
        end
      end

    end

  end
end
