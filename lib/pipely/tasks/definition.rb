require 'rake'
require 'rake/tasklib'
require 'pipely'

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

        directory path

        desc "Graphs the full pipeline definition using Graphviz"
        task name => path do |_, task_args|
          RakeFileUtils.send(:verbose, verbose) do
            if task_block
              task_block.call(*[self, task_args].slice(0, task_block.arity))
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

        File.open(target_filename, 'w') do |file|
          file.write(definition.to_json)
        end
      end

      def target_filename
        "#{path}/#{definition.base_filename}.json"
      end

    end
  end
end