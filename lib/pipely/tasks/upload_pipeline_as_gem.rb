require 'rake'
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
        @storage = Fog::Storage.new({ provider: 'AWS' })
        @directory = @storage.directories.get(@bucket_name)

        bootstrap_helper =
          Pipely::Deploy::Bootstrap.new(@storage, @bucket_name, @s3_gems_path)
        bootstrap_helper.build_and_upload_gems

        # erb context
        context = {
          bootstrap: bootstrap_helper
        }

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
      def upload_to_s3( upload_filename, body )

        s3_dest = File.join(@s3_steps_path, upload_filename)
        puts "uploading #{s3_dest}" if verbose
        @directory.files.create(
          key: s3_dest,
          body: body)
      end
    end
  end
end
