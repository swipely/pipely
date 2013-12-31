require 'spec_helper'
require 'pipely/deploy'

describe Pipely::Deploy::Client do

  describe "#deploy_pipeline" do
    let(:existing_pipeline_ids) { ["pipeline-one", "pipeline-two"] }
    let(:new_pipeline_id) { "pipeline-three" }
    let(:pipeline_name) { "MyPipeline" }
    let(:definition) { "pipeline json" }

    it "gets a list of pipelines, creates a new one, and deletes the others" do
      subject.should_receive(:existing_pipelines).
        and_return(existing_pipeline_ids)

      subject.should_receive(:create_pipeline).
        with(pipeline_name, anything()).
        and_return(new_pipeline_id)

      existing_pipeline_ids.each do |id|
        subject.should_receive(:delete_pipeline).with(id)
      end

      subject.deploy_pipeline(pipeline_name, definition)
    end
  end

end
