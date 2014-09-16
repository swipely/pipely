require 'rake'
require 'aws'
require 'erubis'
require 'pipely/deploy/bootstrap'

module Pipely
  module Tasks
    class UploadPipelineAsGem < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of this rake task
      attr_accessor :name

      attr_accessor :bucket_name
      attr_accessor :s3_steps_path
      attr_accessor :s3_gems_path
      attr_accessor :config

      def initialize(*args, &task_block)
        setup_ivars(args)

        task name, *args do |_, task_args|
          RakeFileUtils.send(:verbose, verbose) do
            if task_block
              task_block.call(*[self, task_args].slice(0, task_block.arity))
            end

            run_task verbose
          end
        end

        Rake::Task["upload_steps"].enhance [name]
      end

      def setup_ivars(args)
        @name = args.shift || 'deploy:upload_pipeline_as_gem'
        @verbose = true
      end

      def run_task(verbose)
        context = build_bootstrap_context

        Dir.glob("templates/*.erb").each do |erb_file|
          upload_filename = File.basename(erb_file).sub( /\.erb$/, '' )

          # Exclude the pipeline.json
          if upload_filename == 'pipeline.json'
            next
          end

          template_erb = Erubis::Eruby.new( File.read(erb_file) )
          upload_to_s3( upload_filename, template_erb.result(context) )
        end
      end

      private
      def s3_bucket
          s3 = AWS::S3.new
          s3.buckets[@bucket_name]
      end

      def build_bootstrap_context
        bootstrap_helper =
          Pipely::Deploy::Bootstrap.new(s3_bucket, @s3_gems_path)
        bootstrap_helper.build_and_upload_gems

        # erb context
        {
          bootstrap: bootstrap_helper.context,
          config: config
        }
      end

      def upload_to_s3( upload_filename, body )

        s3_dest = File.join(@s3_steps_path, upload_filename)
        puts "uploading #{s3_dest}" if verbose
        s3_bucket.objects[s3_dest].write(body)
      end
    end
  end
end
