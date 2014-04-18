require 'aws-sdk'

module Pipely

  # Use AWS SDK to get information about a pipeline
  class AWSClient
    def initialize(pipeline_id)
      configure
      @data_pipeline = AWS::DataPipeline.new
      @pipeline_id = pipeline_id
    end

    def get_log_paths
      ids = get_object_ids_of_type('ShellCommandActivity')
      ids.inject({}) do |memo, id|
        if logs = get_log_paths_for_object(id)
          memo[id] = logs
        end
        memo
      end
    end

    def get_object_ids_of_type(type)
      query_objects(
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

    def get_log_paths_for_object(object_id)
      instance = get_object_instance(object_id)
      stderr, stdout = evaluate_expression(
        '#{stderr + "," + stdout}',
        instance
      ).split(',')

      { stderr: stderr, stdout: stdout }

    rescue AWS::DataPipeline::Errors::InvalidRequestException
      $stderr.puts "Missing stderr and/or stdout fields for #{object_id}"
      nil
    end

    def get_object_instance(object_id)
      evaluate_expression(
        '#{@activeInstances}',
        object_id
      )
    end

    def evaluate_expression(expression, object_id)
      @data_pipeline.client.evaluate_expression({
        expression: expression,
        object_id: object_id,
        pipeline_id: @pipeline_id,
      })[:evaluated_expression]
    end

    def query_objects(query, sphere='COMPONENT')
      @data_pipeline.client.query_objects({
        pipeline_id: @pipeline_id,
        query: query,
        sphere: sphere,
      })[:ids]
    end

    private
    def configure
      if data = File.open(File.expand_path('~/.aws-sdk')).read

        config = YAML.load(data)['default']

        AWS.config(
          access_key_id: config[:access_key_id],
          secret_access_key: config[:secret_access_key],
          region: config[:region]
        )
      end
    end

  end
end
