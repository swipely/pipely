require 'pipely/aws/data_pipeline/api'

module Pipely

  module DataPipeline

    class Attempt

      def initialize(pipeline_id, attempt_id)
        @api = Pipely::DataPipeline::Api.instance.client

        @id = attempt_id
        @pipeline_id = pipeline_id
      end

    end
  end
end
