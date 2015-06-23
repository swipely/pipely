# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/s3_uploader'
require 'tempfile'

describe Pipely::Deploy::S3Uploader do

  subject { described_class.new(s3_bucket, 'test_path/gems') }

  let(:s3_object) { double(:s3_object) }
  let(:bucket_name) { 'a-test-bucket' }
  let(:s3_bucket) { double(:bucket, object: s3_object, name: bucket_name) }

  it "should have bucket name" do
    expect(subject.bucket_name).to eq('a-test-bucket')
  end

  it "should have a s3 path" do
    expect(subject.s3_path).to eq('test_path/gems')
  end

  describe "#upload(files)" do
    let(:files) do
      [
        Tempfile.new('packaged-gem1.gem').path,
        Tempfile.new('built-from-source-gem1.gem').path,
      ]
    end

    it 'uploads each file' do
      allow(s3_object).to receive(:exists?).and_return(true)
      allow(s3_object).to receive(:etag).and_return('mismatch')
      files.each do |file|
        expect(s3_bucket).to receive(:object).with(subject.s3_file_path(file))
      end

      expect(s3_object).to receive(:put).exactly(files.size).times

      subject.upload(files)
    end
  end

end
