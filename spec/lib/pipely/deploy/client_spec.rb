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
             anything(),
             hash_including( 'basename' => pipeline_basename )
        ).
        and_return(new_pipeline_id)

      existing_pipeline_ids.each do |id|
        subject.should_receive(:delete_pipeline).with(id)
      end

      subject.deploy_pipeline(pipeline_basename, definition)
    end
  end

  describe '#create_pipeline' do
    let(:pipeline_name) { "fancy-pipeline" }
    let(:definition) { "pipeline id: @PIPELINE_ID@" }
    let(:changed_definition) { "pipeline id: pipeline-four" }
    let(:new_pipeline_id) { "pipeline-four" }
    let(:pipeline) { double(:pipeline, id: new_pipeline_id) }

    it 'changed the definition contents' do
      subject.instance_variable_get(:@data_pipelines)
        .stub_chain(:pipelines, :create).and_return(pipeline)

      Pipely::Deploy::JSONDefinition.should_receive(:parse)
        .with(changed_definition)

      subject.instance_variable_get(:@aws)
        .should_receive(:put_pipeline_definition)
        .and_return({})
      subject.instance_variable_get(:@aws)
        .should_receive(:activate_pipeline)

      subject.create_pipeline(pipeline_name, definition)

      definition.should eq(changed_definition)
    end
  end

end
