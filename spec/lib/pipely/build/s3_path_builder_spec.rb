require 'pipely/build/s3_path_builder'

describe Pipely::Build::S3PathBuilder do

  subject {
    described_class.new(
      logs: 'log-bucket',
      steps: 'step-bucket',
      assets: 'batch-view-scratch-bucket',
      namespace: 'namespace',
      prefix: 'run-prefix',
    )
  }

  its(:s3_log_prefix) {
    should eq("s3://log-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}")
  }

  its(:s3_step_prefix) {
    should eq("s3://step-bucket/run-prefix")
  }

  its(:s3n_step_prefix) {
    should eq("s3n://step-bucket/run-prefix")
  }

  its(:s3_asset_prefix) {
    should eq("s3://batch-view-scratch-bucket/namespace/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}")
  }

  its(:s3n_asset_prefix) {
    should eq("s3n://batch-view-scratch-bucket/namespace/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}")
  }

  its(:s3_shared_asset_prefix) {
    should eq("s3://batch-view-scratch-bucket/namespace/shared/\#{format(@scheduledStartTime,'YYYY-MM-dd')}")
  }

  describe "#to_hash" do
    it 'includes the necessary keys for supplying config to a Template' do
      expect(subject.to_hash.keys).to match_array([
        :s3_log_prefix,
        :s3_step_prefix,
        :s3n_step_prefix,
        :s3_asset_prefix,
        :s3n_asset_prefix,
        :s3_shared_asset_prefix,
        :bucket_relative_s3_asset_prefix,
      ])
    end
  end

end
