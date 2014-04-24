require 'pipely/aws/data_pipeline/api'
require 'pipely/aws/emr/api'

module Pipely

  module DataPipeline

    class Attempt

      attr_accessor :id

      def initialize(pipeline_id, attempt_id)
        @api = Pipely::DataPipeline::Api.instance.client
        @emr_api = Pipely::Emr::Api.instance

        @id = attempt_id
        @pipeline_id = pipeline_id
      end

      def details
        @details ||= @api.describe_objects(
          object_ids: [@id],
          pipeline_id: @pipeline_id,
        )[:pipeline_objects].first
      end

      def emr_step
        steps = @emr_api.find_emr_steps(emr_cluster[:id], hadoop_call)

        return steps.first if steps.size == 1

        steps.find { |step| error_message.include?(step[:name]) }
      end

      def hadoop_call
        evaluate_expression('#{step}')

      rescue AWS::DataPipeline::Errors::InvalidRequestException
        $stderr.puts "No hadoop step call for attempt #{@id}"
        nil
      end

      def emr_cluster
        cluster_name = @pipeline_id + '_' + resource_name
        @emr_api.find_cluster_by_name(cluster_name)
      end

      def error_message
        details[:fields].find { |field| field[:key] == 'errorMessage' }[:string_value]
      end

      def resource_name
        details[:fields].find { |field| field[:key] == '@resource' }[:ref_value]
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
