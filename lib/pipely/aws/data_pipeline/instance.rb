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
        if type == 'ShellCommandActivity'
          stderr_and_stdout
        elsif type == 'EmrActivity'
          # sleep inbetween attempts to avoid a throttling exception from AWS API
          attempts.map { |attempt| logs = attempt.emr_step_logs; sleep 1 ; logs }
        end
      end

      def stderr_and_stdout
        stderr, stdout = evaluate_expression(
          '#{stderr + "," + stdout}',
        ).split(',')

        { stderr: stderr, stdout: stdout }

      rescue AWS::DataPipeline::Errors::InvalidRequestException => ex
        $stderr.puts ex.inspect
        $stderr.puts "No stderr and stdout fields for ShellCommandActivity #{@id}"
        nil
      end

      def type
        @type ||= evaluate_expression('#{type}')
      end

      def emr_steps
        return if type != 'EmrActivity'
        attempts.map { |attempt| { attempt: attempt.id, emr_step: attempt.emr_step } }
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
