require 'pipely/aws/data_pipeline/api'
require 'pipely/aws/data_pipeline/attempt'

module Pipely

  module DataPipeline

    class Instance

      attr_accessor :id

      def initialize(pipeline_id, instance_id)
        @api = Pipely::DataPipeline::Api.instance.client

        @id = instance_id
        @pipeline_id = pipeline_id
      end

      def log_paths
        stderr, stdout = evaluate_expression(
          '#{stderr + "," + stdout}',
        ).split(',')

        { stderr: stderr, stdout: stdout }

      rescue AWS::DataPipeline::Errors::InvalidRequestException => ex
        $stderr.puts ex.inspect
        $stderr.puts "Can't find log paths for #{@id}"
        nil
      end

      def attempts
        query = {
          selectors: [ {
            field_name: '@instanceParent',
            operator: {
              type: 'REF_EQ',
              values: [@id]
            }
          } ]
        }

        @api.query_objects(
          pipeline_id: @pipeline_id,
          sphere: 'ATTEMPT',
          query: query
        )[:ids].map { |id| Pipely::DataPipeline::Attempt.new(@pipeline_id, id) }
      end

      def evaluate_expression(expression)
        @api.evaluate_expression({
          expression: expression,
          object_id: @id,
          pipeline_id: @pipeline_id,
        })[:evaluated_expression]
      end

    end
  end
end
