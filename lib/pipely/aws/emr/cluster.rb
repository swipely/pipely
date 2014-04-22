require 'pipely/aws_client'

module Pipely

  module Emr

    class InstanceGroup < Pipely::AWSClient

      def initialize(instance_group_id)
        super()

        @id = instance_group_id
      end

      def log_paths
      end

    end
  end
end
