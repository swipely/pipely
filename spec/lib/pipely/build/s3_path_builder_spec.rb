require 'pipely/build/s3_path_builder'

describe Pipely::Build::S3PathBuilder do

  subject {
    described_class.new(
      logs: 'log-bucket',
      steps: 'step-bucket',
      assets: 'asset-bucket',
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
    should eq("s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}")
  }

  its(:s3n_asset_prefix) {
    should eq("s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}")
  }

  its(:s3_shared_asset_prefix) {
    should eq("s3://asset-bucket/run-prefix/shared/\#{format(@scheduledStartTime,'YYYY-MM-dd')}")
  }

  its(:bucket_relative_s3_asset_prefix) {
    should eq("run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}")
  }

  describe "#to_hash" do
    it 'includes the necessary keys for supplying config to a Template' do
      expect(subject.to_hash.keys).to include(
        :s3_log_prefix,
        :s3_step_prefix,
        :s3n_step_prefix,
        :s3_asset_prefix,
        :s3n_asset_prefix,
        :s3_shared_asset_prefix,
        :bucket_relative_s3_asset_prefix,
      )
    end
  end

  context "when a custom template is specified via config" do
    subject {
      described_class.new(
        foo: 'my-value',
        templates: {
          bar: ':protocol://my-bucket/:foo/okay'
        }
      )
    }

    its(:s3_bar_prefix) {
      should eq('s3://my-bucket/my-value/okay')
    }

    its(:s3n_bar_prefix) {
      should eq('s3n://my-bucket/my-value/okay')
    }

    describe "#to_hash" do
      it 'includes the keys for the custom template' do
        expect(subject.to_hash.keys).to include(
          :s3_bar_prefix,
          :s3n_bar_prefix,
        )
      end
    end
  end

end
