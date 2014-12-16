require 'fog'
require 'time_diff'

module Pipely

  TaskState = Struct.new(
    :component_id,
    :start_time,
    :end_time,
    :depends_on,
    :scheduled_start,
    :status
  )

  # Uses Fog to communicate with the AWS Data Pipeline service
  class FogClient < Struct.new(:pipeline_id)

    def definition
      objects = data_pipeline.get_pipeline_definition(pipeline_id)

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
      init_all_mappings

      all_instances.each do |pipeline_object|
        process_pipeline_object(pipeline_object)
      end
      improve_start_times
      compute_task_states
    end

    private

    def init_all_mappings
      @task_states_by_scheduled_start = {}
      @task_states = {}  # component_id => TaskState
      @id_to_component_id = {}  # key => component_id
    end

    def all_instances
      c = data_pipeline

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

    def process_pipeline_object(pipeline_object)
      task_state = task_state_from_pipeline_object(pipeline_object)

      @id_to_component_id[pipeline_object['id']] = task_state.component_id
      @task_states[task_state.component_id] = task_state
    end

    def task_state_from_pipeline_object(pipeline_object)
      task_state = TaskState.new
      task_state.depends_on = []

      pipeline_object['fields'].each do |field|
        case field['key']
        when '@actualEndTime'
          task_state.end_time = field['stringValue']
        when '@actualStartTime'
          task_state.start_time = field['stringValue']
        when '@componentParent'
          task_state.component_id = field['refValue']
        when '@status'
          task_state.status = field['stringValue']
        when '@scheduledEndTime'
          task_state.end_time ||= field['stringValue']
        when '@scheduledStartTime'
          task_state.scheduled_start = field['stringValue']
          task_state.start_time ||= task_state.scheduled_start
        when 'dependsOn'
          task_state.depends_on << field['refValue']
        end
      end

      task_state
    end


    def date_from_field(field)
      DateTime.parse(field['stringValue'])
    end

    def improve_start_times
      @task_states.each do |component_id, state|
        state.depends_on.each do |dep_id|
          dep_component_id = @id_to_component_id[dep_id]
          dep_end_time = @task_states[dep_component_id].end_time
          state.start_time = [state.start_time, dep_end_time].max
        end
      end
    end

    def compute_task_states
      @task_states.each do |component_id, state|
        @task_states_by_scheduled_start[state.scheduled_start] ||= {}
        @task_states_by_scheduled_start[state.scheduled_start][component_id] = {
          execution_state: state.status,
          run_time: Time.diff(state.start_time, state.end_time)[:diff]
        }
      end

      @task_states_by_scheduled_start
    end

    def data_pipeline
      Fog::AWS::DataPipeline.new
    rescue ArgumentError
      $stderr.puts "#{self.class.name}: Falling back to IAM profile"
      Fog::AWS::DataPipeline.new(use_iam_profile: true)
    end

  end
end
