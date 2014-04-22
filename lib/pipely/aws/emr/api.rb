require_relative '../configure_aws'
require 'aws-sdk'
require 'singleton'

module Pipely

  module Emr

    class Api
      include Pipely::ConfigureAws
      include Singleton

      attr_accessor :client

      def initialize
        super()

        configure

        @client = AWS::EMR.new.client
      end

      def step_details_for_cluster(cluster_id)
        client.list_steps(cluster_id: cluster_id).data[:steps].map do |step|
          client.describe_step(cluster_id: cluster_id, step_id: step[:id])
        end
      end
    end

  end

end
