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
        @cluster_steps = {}
        @clusters = {}
      end

      # return info about the emr steps that ran in this cluster
      # with a particular hadoop jar file and arguments
      def find_emr_steps(cluster_id, hadoop_call)
        steps = describe_all_steps(cluster_id).find_all do |step|
          cfg = step[:config]
          step_hadoop_call = cfg[:jar] + ',' + cfg[:args].join(',')
          step_hadoop_call == hadoop_call
        end

        steps.map do |step|
          {
            id: step[:id],
            name: step[:name],
            status: step[:status],
          }
        end
      end

      def find_cluster_by_name(name)
        return @clusters[name] if @clusters[name]

        @cluster_list ||= client.list_clusters

        cluster_id = @cluster_list.data[:clusters].find do |cluster|
          cluster[:name] == name
        end[:id]

        @clusters[name] = client.describe_cluster(cluster_id: cluster_id)[:cluster]
      end

      # gets details on all steps for a cluster
      # memoizes by cluster_id
      def describe_all_steps(cluster_id)
        return @cluster_steps[cluster_id] if @cluster_steps[cluster_id]

        @cluster_steps[cluster_id] = (
          client.list_steps(cluster_id: cluster_id).data[:steps].map do |step|
            client.describe_step(cluster_id: cluster_id, step_id: step[:id]).data[:step]
          end
        )
      end

    end

  end

end
