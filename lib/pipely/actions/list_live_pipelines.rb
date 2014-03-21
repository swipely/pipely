module Pipely
  module Actions

    # List currently deployed pipelines
    #
    class ListLivePipelines

      def initialize(options)
        @options = options
      end

      def execute
        if @options.json_output
          $stdout.puts pipeline_ids.to_json
        else
          $stdout.puts pipeline_ids.map { |pipeline|
            [ pipeline['name'], pipeline['id'] ].join("\t")
          }
        end
      end

    private

      def pipeline_ids
        ids = []

        begin
          result = data_pipeline.list_pipelines
          ids += result['pipelineIdList']
        end while (result['hasMoreResults'] && result['marker'])

        ids
      end

      def data_pipeline
        Fog::AWS::DataPipeline.new
      rescue ArgumentError
        $stderr.puts "#{self.class.name}: Falling back to IAM profile"
        Fog::AWS::DataPipeline.new(use_iam_profile: true)
      end

    end

  end
end
