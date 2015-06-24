require 'aws-sdk'
require 'logger'
require 'tempfile'
require 'securerandom'
require 'pipely/deploy/json_definition'

module Pipely
  module Deploy

    # Client for managing deployment of rendered definitions.
    #
    class Client

      attr_reader :base_tags

      # Generic error representing failure to deploy a rendered definition.
      class PipelineDeployerError < RuntimeError; end

      def initialize(log=nil)
        @log = log || Logger.new(STDOUT)
        @aws = Aws::DataPipeline::Client.new
        @base_tags = {
          "environment" => ENV['env'],
          "creator" => ENV['USER']
        }
      end

      def deploy_pipeline(pipeline_basename, definition = nil, &block)
        pipeline_name = pipeline_name(pipeline_basename)

        tags = base_tags.merge(
          "basename" => pipeline_basename,
          "deploy_id" => SecureRandom.uuid )

        # Get a list of all existing pipelines
        pipeline_ids = existing_pipelines(pipeline_name)
        @log.info("#{pipeline_ids.count} existing pipelines: #{pipeline_ids}")

        # Create new pipeline
        created_pipeline_id = create_pipeline(
          pipeline_name, definition, tags, &block
        )

        if created_pipeline_id
          @log.info("Created pipeline id '#{created_pipeline_id}'")

          # Delete old pipelines
          pipeline_ids.each do |pipeline_id|
            begin
              delete_pipeline(pipeline_id)
              @log.info("Deleted pipeline '#{pipeline_id}'")

            rescue PipelineDeployerError => error
              @log.warn(error)
            end
          end
        end

        created_pipeline_id
      end

      def existing_pipelines(pipeline_name)
        ids = []
        marker = nil

        begin
          options = marker ? { marker: marker } : {}
          result = @aws.list_pipelines(options)

          ids += result[:pipeline_id_list].
                   select { |p| p[:name] == pipeline_name }.
                   map { |p| p[:id] }

        end while (result[:has_more_results] && marker = result[:marker])

        ids
      end

      def create_pipeline(pipeline_name, definition, tags={})
        created_pipeline = @aws.create_pipeline(
          name: pipeline_name,
          unique_id: tags['deploy_id'] || SecureRandom.uuid,
          description: "Pipely Deployed Data Pipeline",
          tags: base_tags.merge(tags).map do |k,v|
            { key: k, value: v } unless v.nil?
          end.compact,
        )

        definition ||= yield(created_pipeline.pipeline_id) if block_given?

        response = @aws.put_pipeline_definition(
          pipeline_id: created_pipeline.pipeline_id,
          pipeline_objects: JSONDefinition.parse(definition)
        )

        activate_pipeline(response, created_pipeline)
      end

      def activate_pipeline(response, pipeline)
        if response[:errored]
          @log.error("Failed to put pipeline definition.")
          @log.error(response[:validation_errors].inspect)
          false
        else
          @aws.activate_pipeline(pipeline_id: pipeline.pipeline_id)
          pipeline.pipeline_id
        end
      end

      def delete_pipeline(pipeline_id)
        @aws.delete_pipeline(pipeline_id: pipeline_id)
      end

      private

      def pipeline_name(basename)
        [
          ('P' if ENV['env'] == 'production'),
          ENV['USER'],
          basename
        ].compact.join(':')
      end
    end
  end
end
