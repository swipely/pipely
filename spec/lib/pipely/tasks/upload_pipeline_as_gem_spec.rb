# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/tasks/upload_pipeline_as_gem'

describe Pipely::Tasks::UploadPipelineAsGem do

  describe "#run_task" do
    subject do
      described_class.new.tap do |task|
        task.config = config
        task.s3_steps_path = s3_steps_path
        task.bucket_name = bucket_name
        task.s3_gems_path = s3_gems_path
        task.templates = templates
      end
    end
    let(:config) do
       { "bootstrap_mixins" => "Fixtures::BootstrapContexts::Simple" }
    end
    let(:gem_files) do
      {
        'packaged-gem1' => '/path/to/cache/packaged-gem1.gem',
        'built-from-source-gem1' => '/path/to/cache/built-from-source-gem1.gem',
      }
    end
    let(:bucket_name) { 'bucket-test' }
    let(:s3_steps_path) { "s3/steps" }
    let(:s3_gems_path) { "s3/gems" }
    let(:templates) { ['spec/fixtures/templates/bootstrap.sh.erb']}

    before do
      allow(Rake::Task).to receive(:[]).with("upload_steps") do
         double(enhance: ["deploy:upload_pipeline_as_gem"])
      end

      # Resolves gems for Pipeline
      expect(Pipely::Bundler).to receive(:gem_files) { gem_files }

      # Uploads gems to S3
      expect(Pipely::Deploy::S3Uploader).to receive(:new) do
        mock(
          upload: gem_files.values,
          s3_urls: gem_files.values
        )
      end

      # Compiles the erb, using the configued mixin
      expect(subject).to receive(:upload_to_s3).with(
        "bootstrap.sh", "one\ntwo\nthree\nsimple\n")
    end

    it "should invoke" do
      # All the magic happens in the mocks
      expect(subject.run_task(true)).to eql(
        ["spec/fixtures/templates/bootstrap.sh.erb"])
    end
  end
end
