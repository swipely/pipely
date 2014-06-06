require 'fog'
require 'logger'
require 'tempfile'
require 'uuidtools'

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
      end

      def deploy_pipeline(pipeline_type, definition)
        pipeline_name = [
          ('P' if ENV['env'] == 'production'),
          ENV['USER'],
          pipeline_type
        ].compact.join(':')

        # Get a list of all existing pipelines
        pipeline_ids = existing_pipelines(pipeline_name)
        @log.info("#{pipeline_ids.count} existing pipelines: #{pipeline_ids}")

        # Create new pipeline
        created_pipeline_id = create_pipeline(pipeline_name,
                                              definition,
                                              pipeline_type)
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

      def existing_pipelines(pipeline_name)
        ids = []

        begin
          result = Fog::AWS[:data_pipeline].list_pipelines

          ids += result['pipelineIdList'].
                   select { |p| p['name'] == pipeline_name }.
                   map { |p| p['id'] }

        end while (result['hasMoreResults'] && result['marker'])

        ids
      end

      def create_pipeline(pipeline_name, definition, pipeline_type)
        definition_objects = JSON.parse(definition)['objects']

        unique_id = UUIDTools::UUID.random_create

        created_pipeline = @data_pipelines.pipelines.create(
          unique_id: unique_id,
          name: pipeline_name,
          tags: {
            "environment" => ENV['env'],
            "creator" => ENV['USER'],
            "type" => pipeline_type
          }
        )

        created_pipeline.put(definition_objects)
        created_pipeline.activate

        created_pipeline.id
      end

      def delete_pipeline(pipeline_id)
        @data_pipelines.pipelines.get(pipeline_id).destroy
      end

    end
  end
end
