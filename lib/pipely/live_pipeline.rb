require 'pipely/runs_report'

module Pipely

  # Represent a pipeline that has been deployed to AWS DataPipeline
  class LivePipeline
    attr_reader :pipeline_id

    def initialize(pipeline_id)
      @pipeline_id = pipeline_id

      @definition_json = definition(pipeline_id)
      @task_states_by_scheduled_start = task_states_by_scheduled_start

      unless @definition_json
        raise "No definition found for #{client.pipeline_id}"
      end

      if @task_states_by_scheduled_start.empty?
        raise "No runs found for #{client.pipeline_id}"
      end
    end

    def print_runs_report
      RunsReport.new(@task_states_by_scheduled_start).print
    end

    def render_latest_graph(output_path=nil)
      latest_start = @task_states_by_scheduled_start.keys.max
      task_states = @task_states_by_scheduled_start[latest_start]
      render_graph(latest_start, task_states, output_path)
    end

    def render_graphs(output_path=nil)
      @task_states_by_scheduled_start.map do |start, task_states|
        render_graph(start, task_states, output_path)
      end
    end

    private

    def data_pipeline
      @data_pipeline ||= Aws::DataPipeline::Client.new
    end

    def render_graph(start, task_states, output_path)
      utc_time = Time.now.to_i
      formatted_start = start.gsub(/[:-]/, '').sub('T', '-')

      output_base = "#{@pipeline_id}-#{formatted_start}-#{utc_time}.png"
      filename = File.join((output_path || 'graphs'), output_base)

      Pipely.draw(@definition_json, filename, task_states)
    end

    def definition(pipeline_id)
      objects = data_pipeline.get_pipeline_definition(pipeline_id: pipeline_id)
      { objects: flatten_pipeline_objects(objects.pipeline_objects) }.to_json
    end

    def task_states_by_scheduled_start
      task_states_by_scheduled_start = {}

      all_instances.each do |pipeline_object|
        component_id = status = scheduled_start = nil

        pipeline_object.fields.each do |field|
          case field.key
          when '@componentParent'
            component_id = field.ref_value
          when '@status'
            status = field.string_value
          when '@scheduledStartTime'
            scheduled_start = field.string_value
          end
        end

        task_states_by_scheduled_start[scheduled_start] ||= {}
        task_states_by_scheduled_start[scheduled_start][component_id] = {
          execution_state: status
        }
      end

      task_states_by_scheduled_start
    end

    def all_instances
      pipeline_objects = []
      marker = nil

      begin
        result = data_pipeline.query_objects(
          pipeline_id: pipeline_id,
          sphere: "INSTANCE",
          marker: marker,
        )

        marker = result.marker

        instance_details = data_pipeline.describe_objects(
          pipeline_id: pipeline_id,
          object_ids: result.ids
        )

        data_pipeline.describe_objects(
          pipeline_id: pipeline_id,
          object_ids: result.ids
          )
        pipeline_objects += instance_details.pipeline_objects

      end while (result.has_more_results && marker)

      pipeline_objects
    end


    def flatten_pipeline_objects(objects)
      objects.each_with_object([]) do |object, result|
        h = {
          id: object.id,
          name: object.name,
        }

        object.fields.each do |field|
          k = field.key
          if field.ref_value
            h[k] ||= []
            h[k] << { ref: field.ref_value }
          else
            h[k] = field.string_value
          end
        end

        result << h
      end
    end
  end
end
