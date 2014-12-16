require 'rake'
require 'rake/tasklib'
require 'pipely/deploy'

module Pipely
  module Tasks
    class Deploy < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of task.
      #
      # default:
      #   :deploy
      attr_accessor :name

      # Pipeline definition instance
      attr_accessor :definition

      # Use verbose output. If this is set to true, the task will print the
      # local and remote paths of each step file it uploads to S3.
      #
      # default:
      #   true
      attr_accessor :verbose

      def initialize(*args, &task_block)
        setup_ivars(args)

        # First non-name parameter allows overriding the configured scheduler.
        args.unshift(:scheduler)

        desc "Deploy pipeline" unless ::Rake.application.last_comment

        task name, *args do |_, task_args|
          RakeFileUtils.send(:verbose, verbose) do
            if task_block
              task_block.call(*[self, task_args].slice(0, task_block.arity))
            end

            if scheduler_override = task_args[:scheduler]
              definition.config[:scheduler] = scheduler_override
            end

            run_task verbose
          end
        end
      end

      def setup_ivars(args)
        @name = args.shift || :deploy
        @verbose = true
      end

      def run_task(verbose)
        Rake::Task["upload_steps"].invoke

        Pipely::Deploy::Client.new
          .deploy_pipeline(definition.pipeline_name) do |pipeline_id|
            definition.pipeline_id = pipeline_id
            definition.to_json
          end
      end

    end
  end
end
