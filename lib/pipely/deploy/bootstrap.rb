require 'pipely/bundler'
require 'pipely/deploy/bootstrap_context'
require 'pipely/deploy/bootstrap_registry'
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

      def context(*mixins)
        bootstrap_mixins = BootstrapRegistry.instance.register_mixins(mixins)

        BootstrapContext.class_eval do
          bootstrap_mixins.each do |mixin|
            puts "Adding bootstrap mixin #{mixin}"
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
