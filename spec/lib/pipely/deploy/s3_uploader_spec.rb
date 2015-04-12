# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/s3_uploader'
require 'tempfile'

describe Pipely::Deploy::S3Uploader do

  subject { described_class.new(s3_bucket, 'test_path/gems') }

  let(:s3_bucket) do
     s3 = Aws::S3::Bucket.new('a-test-bucket')
  end

  it "should have bucket name" do
    expect(subject.bucket_name).to eq('a-test-bucket')
  end

  it "should have a s3 path" do
    expect(subject.s3_path).to eq('test_path/gems')
  end

  describe "#upload(files)" do
    let(:objects) { double(:objects) }

    let(:s3_object) do
      double('s3_object', write: nil, exists?: true, etag: 'mismatch')
    end

    let(:files) do
      [
        Tempfile.new('packaged-gem1.gem').path,
        Tempfile.new('built-from-source-gem1.gem').path,
      ]
    end

    before do
      allow(objects).to receive(:[]) { s3_object }
      allow(s3_bucket).to receive(:objects) { objects }
    end

    it 'uploads each file' do
      files.each do |file|
        expect(objects).to receive(:[]).with(subject.s3_file_path(file))
      end

      expect(s3_bucket).to receive(:objects).exactly(files.size).times

      subject.upload(files)
    end
  end

end
