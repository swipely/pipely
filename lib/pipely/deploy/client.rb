# Note: We are in the process of migrating from Fog to aws-sdk for communicating
# with the Data Pipeline API.  aws-sdk offers several benefits, such as:
#
# * Built-in automated exponential back-off, to avoid hitting rate limits.
# * Working pagination of ListPipelines responses.
# * Authentication using IAM resource roles.
# * Faster installation.
#
# On the downside, aws-sdk does not yet support tagging of pipelines.  We can
# not yet port pipely entirely away from Fog until this is resolved, so we will
# temporarily require both libraries.

require 'fog'
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

      # Generic error representing failure to deploy a rendered definition.
      class PipelineDeployerError < RuntimeError; end

      def initialize(log=nil)
        @log = log || Logger.new(STDOUT)
        @data_pipelines = Fog::AWS::DataPipeline.new
        @aws = AWS::DataPipeline.new.client
      end

      def deploy_pipeline(pipeline_basename, definition)
        pipeline_name = [
          ('P' if ENV['env'] == 'production'),
          ENV['USER'],
          pipeline_basename
        ].compact.join(':')

        tags = { "basename" => pipeline_basename }

        # Get a list of all existing pipelines
        pipeline_ids = existing_pipelines(pipeline_name)
        @log.info("#{pipeline_ids.count} existing pipelines: #{pipeline_ids}")

        # Create new pipeline
        created_pipeline_id = create_pipeline(pipeline_name,
                                              definition,
                                              tags)
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
        # Use Fog gem, instead of aws-sdk gem, to create pipeline with tags.
        #
        # TODO: Consolidate on aws-sdk when tagging support is added.
        #
        created_pipeline = @data_pipelines.pipelines.create(
          unique_id: SecureRandom.uuid,
          name: pipeline_name,
          tags: default_tags.merge(tags)
        )

        # Use aws-sdk gem, instead of Fog, to put definition and activate
        # pipeline, for improved reporting of validation errors.
        #
        response = @aws.put_pipeline_definition(
          pipeline_id: created_pipeline.id,
          pipeline_objects: JSONDefinition.parse(definition)
        )

        if response[:errored]
          @log.error("Failed to put pipeline definition.")
          @log.error(response[:validation_errors].inspect)
          false
        else
          @aws.activate_pipeline(pipeline_id: created_pipeline.id)
          created_pipeline.id
        end
      end

      def delete_pipeline(pipeline_id)
        @data_pipelines.pipelines.get(pipeline_id).destroy
      end

    private

      def default_tags
        {
          "environment" => ENV['env'],
          "creator" => ENV['USER']
        }
      end

    end
  end
end
