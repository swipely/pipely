require 'pipely/aws_client'
require 'pipely/aws/data_pipeline/instance'

module Pipely

  module DataPipeline

    class Component < Pipely::AWSClient

      def initialize(pipeline_id, component_id)
        super()

        @id = component_id
        @pipeline_id = pipeline_id
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
