require 'pipely/aws/data_pipeline/api'
require 'pipely/aws/emr/api'
require 'pipely/aws/data_pipeline/component'

module Pipely

  module DataPipeline

    class Pipeline

      def initialize(pipeline_id)
        @api = Pipely::DataPipeline::Api.instance.client
        @emr_api = Pipely::Emr::Api.instance
        @id = pipeline_id
      end

      def emr_steps_for_component(component_id)
        Component.new(@id, component_id).active_instances.emr_steps
      end

      def log_paths
        ids = get_components_of_type('ShellCommandActivity')

        ids.inject({}) do |memo, component_id|
          logs = log_paths_for_component(component_id)
          memo[component_id] = logs if logs

          memo
        end
      end

      def log_paths_for_component(component_id)
        Pipely::DataPipeline::Component.new(
          @id,
          component_id
        ).active_instances.log_paths
      end

      def get_components_of_type(type)
        query_components(
          selectors: [
            {
              field_name: 'type',
              operator: {
                type: 'EQ',
                values: [type],
              }
            }
          ]
        )
      end

      def query_components(query)
        ids = @api.query_objects({
          pipeline_id: @id,
          query: query,
          sphere: 'COMPONENT',
        })[:ids]
      end

      def evaluate_expression(expression, object_id)
        @api.evaluate_expression({
          expression: expression,
          object_id: object_id,
          pipeline_id: @id,
        })[:evaluated_expression]
      end

    end
  end
end
