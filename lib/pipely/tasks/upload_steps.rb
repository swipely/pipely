require 'rake'
require 'rake/tasklib'
require 'fog'

module Pipely
  module Tasks
    class UploadSteps < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of task.
      #
      # default:
      #   :upload_steps
      attr_accessor :name

      # Local path to where the step files are.
      #
      # default:
      #   "steps"
      attr_accessor :local_path

      # Name of S3 bucket to upload steps to.
      attr_accessor :s3_bucket_name

      # Path within S3 bucket to upload steps to.
      attr_accessor :s3_path

      # Use verbose output. If this is set to true, the task will print the
      # local and remote paths of each step file it uploads to S3.
      #
      # default:
      #   true
      attr_accessor :verbose

      def initialize(*args, &task_block)
        setup_ivars(args)

        unless ::Rake.application.last_comment
          desc "Upload Data Pipeline steps to S3"
        end

        task name, *args do |_, task_args|
          RakeFileUtils.send(:verbose, verbose) do
            if task_block
              task_block.call(*[self, task_args].slice(0, task_block.arity))
            end

            run_task verbose
          end
        end
      end

      def setup_ivars(args)
        @name = args.shift || :upload_steps
        @verbose = true
        @local_path = "steps"
      end

      def run_task(verbose)
        with_bucket do |directory|
          step_files.each do |file_name|
            dest = file_name.sub(/^#{local_path}/, s3_path)
            puts "uploading #{dest}" if verbose
            directory.files.create(key: dest, body: File.read(file_name))
          end
        end
      end

    private

      def with_bucket
        storage = Fog::Storage.new({ provider: 'AWS' })
        if directory = storage.directories.detect{ |d| d.key == s3_bucket_name }
          yield(directory)
        else
          raise "Couldn't find S3 bucket '#{s3_bucket_name}'"
        end
      end

      def step_files
        FileList.new(File.join(local_path, "**", "*")).reject { |fname|
          File.directory?( fname )
        }
      end

    end
  end
end
