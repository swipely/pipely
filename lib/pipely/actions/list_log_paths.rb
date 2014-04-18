require 'pp'
require 'pipely/aws_client'

module Pipely
  module Actions

    # List currently deployed pipelines
    #
    class ListLogPaths

      def initialize(options)
        @options = options
      end

      def execute
        if @options.object_id
          $stdout.puts PP.pp(log_paths_for_object, "")
        else
          $stdout.puts PP.pp(log_paths, "")
        end
      end

    private

      def log_paths
        data_pipeline.get_log_paths
      end

      def log_paths_for_object
        data_pipeline.get_log_paths_for_object(@options.object_id)
      end

      def data_pipeline
        Pipely::AWSClient.new(@options.pipeline_id)
      end

    end

  end
end
