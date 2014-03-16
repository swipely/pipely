require 'fog'

module Pipely

  # Uses Fog to communicate with the AWS Data Pipeline service
  class FogClient < Struct.new(:pipeline_id)

    def definition
      objects = Fog::AWS[:data_pipeline].get_pipeline_definition(pipeline_id)

      flattened_objects = []

      objects['pipelineObjects'].each do |object|
        h = {
          id: object['id'],
          name: object['name'],
        }

        object['fields'].each do |field|
          k = field['key']
          if field['refValue']
            h[k] ||= []
            h[k] << { ref: field['refValue'] }
          else
            h[k] = field['stringValue']
          end
        end

        flattened_objects << h
      end

      { objects: flattened_objects }.to_json
    end

    def task_states_by_scheduled_start
      task_states_by_scheduled_start = {}

      all_instances.each do |pipeline_object|
        component_id = status = scheduled_start = nil

        pipeline_object['fields'].each do |field|
          case field['key']
          when '@componentParent'
            component_id = field['refValue']
          when '@status'
            status = field['stringValue']
          when '@scheduledStartTime'
            scheduled_start = field['stringValue']
          end
        end

        task_states_by_scheduled_start[scheduled_start] ||= {}
        task_states_by_scheduled_start[scheduled_start][component_id] = {
          execution_state: status
        }
      end

      task_states_by_scheduled_start
    end

  private

    def all_instances
      c = Fog::AWS[:data_pipeline]

      result = {}
      pipeline_objects = []

      begin
        if result['marker']
          marker = JSON.parse(result['marker'])['primary']
        end

        result = c.query_objects(
          pipeline_id,
          'INSTANCE',
          marker: result['marker']
        )

        instance_details = c.describe_objects(pipeline_id, result['ids'])
        pipeline_objects += instance_details['pipelineObjects']

      end while (result['hasMoreResults'] && result['marker'])

      pipeline_objects
    end

  end
end
