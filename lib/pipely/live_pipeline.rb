require 'pipely/fog_client'
require 'pipely/runs_report'

module Pipely

  # Represent a pipeline that has been deployed to AWS DataPipeline
  class LivePipeline

    def initialize(pipeline_id)
      @pipeline_id = pipeline_id

      client = FogClient.new(pipeline_id)
      @definition_json = client.definition
      @task_states_by_scheduled_start = client.task_states_by_scheduled_start

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

    def render_graphs(output_path=nil)
      @task_states_by_scheduled_start.map do |start, task_states|
        utc_time = Time.now.to_i
        formatted_start = start.gsub(/[:-]/, '').sub('T', '-')

        output_base = "#{@pipeline_id}-#{formatted_start}-#{utc_time}.png"
        filename = File.join((output_path || 'graphs'), output_base)

        Pipely.draw(@definition_json, filename, task_states)
      end

    end

  end
end
