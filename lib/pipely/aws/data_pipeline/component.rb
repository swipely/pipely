require 'pipely/aws/data_pipeline/instance'
require 'pipely/aws/data_pipeline/attempt'
require 'pipely/aws/data_pipeline/api'

module Pipely

  module DataPipeline

    class Component

      def initialize(pipeline_id, component_id)
        @api = Pipely::DataPipeline::Api.instance.client
        @id = component_id
        @pipeline_id = pipeline_id
      end

      def attempts
        query = {
          selectors: [ {
            field_name: '@componentParent',
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
        )[:ids].map do |id|
          Pipely::DataPipeline::Attempt.new(
            @pipeline_id,
            id
          )
        end
      end

      def active_instances
        Pipely::DataPipeline::Instance.new(
          @pipeline_id,
          @id,
          evaluate_expression('#{@activeInstances}')
        )
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
