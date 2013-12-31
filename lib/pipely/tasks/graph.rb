require 'rake'
require 'rake/tasklib'
require 'pipely'

module Pipely
  module Tasks
    class Graph < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of task.
      #
      # default:
      #   :graph
      attr_accessor :name

      # Path to write graph images to.
      #
      # default:
      #   "graphs"
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

        # create the `path` directory if it doesn't exist
        directory path

        namespace name do
          task :full => path do |_, task_args|
            RakeFileUtils.send(:verbose, verbose) do
              if task_block
                task_block.call(*[self, task_args].slice(0, task_block.arity))
              end

              run_task verbose
            end
          end

          task :open => :full do
            `open #{target_filename}`
          end
        end

        desc "Graphs the full pipeline definition using Graphviz"
        task name => "#{name}:full"
      end

      def setup_ivars(args)
        @name = args.shift || :graph
        @verbose = true
        @path = "graphs"
      end

      def run_task(verbose)
        puts "Generating #{target_filename}" if verbose
        Pipely.draw(definition.to_json, target_filename)
      end

      def target_filename
        "#{path}/#{definition.base_filename}.png"
      end

    end
  end
end
