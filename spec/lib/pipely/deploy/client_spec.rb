require 'spec_helper'
require 'pipely/deploy'

describe Pipely::Deploy::Client do

  describe "#deploy_pipeline" do
    let(:existing_pipeline_ids) { ["pipeline-one", "pipeline-two"] }
    let(:new_pipeline_id) { "pipeline-three" }
    let(:pipeline_basename) { "MyPipeline" }
    let(:definition) { "pipeline json" }

    it "gets a list of pipelines, creates a new one, and deletes the others" do
      subject.should_receive(:existing_pipelines).
        and_return(existing_pipeline_ids)

      subject.should_receive(:create_pipeline).
        with("#{ENV['USER']}:#{pipeline_basename}",
             nil,
             hash_including( 'basename' => pipeline_basename )
        ).
        and_return(new_pipeline_id)

      existing_pipeline_ids.each do |id|
        subject.should_receive(:delete_pipeline).with(id)
      end

      subject.deploy_pipeline(pipeline_basename) { definition }
    end
  end

  describe '#create_pipeline' do
    let(:pipeline_name) { 'NewPipeline' }
    let(:pipeline_id) { 123 }
    let(:created_pipeline) do
      double(:created_pipeline, pipeline_id: pipeline_id)
    end
    let(:definition) { "Pipeline ID: 123" }

    let(:aws) { subject.instance_variable_get(:@aws) }

    it 'gets the definition from the block' do

      Pipely::Deploy::JSONDefinition.should_receive(:parse).with(definition)

      aws.should_receive(:create_pipeline).and_return(created_pipeline)
      aws.should_receive(:put_pipeline_definition).and_return({})
      aws.should_receive(:activate_pipeline)
      subject.create_pipeline(pipeline_name, nil) do |pipeline_id|
        "Pipeline ID: #{pipeline_id}"
      end
    end
  end

end
