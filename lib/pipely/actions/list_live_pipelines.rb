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
            [ pipeline.name, pipeline.id ].join("\t")
          }
        end
      end

      private

      def pipeline_ids
        ids = []

        data_pipeline = Aws::DataPipeline::Client.new


        marker = nil
        begin
          result = data_pipeline.list_pipelines(
            marker: marker,
          )
          ids += result.pipeline_id_list
          marker = result.marker
        end while (result.has_more_results && marker)

        ids
      end
    end

  end
end
