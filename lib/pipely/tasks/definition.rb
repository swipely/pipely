require 'rake'
require 'rake/tasklib'
require 'pipely'
require 'json'
require 'fileutils'

module Pipely
  module Tasks
    class Definition < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of task.
      #
      # default:
      #   :definition
      attr_accessor :name

      # Path where rendered definitions are written.
      #
      # default:
      #   "definitions"
      attr_accessor :path

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

        directory path

        desc "Generates the pipeline definition file"
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
        @name = args.shift || :definition
        @verbose = true
        @path = "definitions"
      end

      def run_task(verbose)
        puts "Generating #{target_filename}" if verbose

        json = definition.to_json

        unless ENV['UGLY']
          json = JSON.pretty_generate(JSON.parse(json))
        end

        File.open(target_filename, 'w') do |file|
          file.write(json)
        end
      end

      def target_filename
        "#{path}/#{definition.base_filename}.json"
      end

    end
  end
end
