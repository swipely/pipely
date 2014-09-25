# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap'
require 'fileutils'

describe Pipely::Deploy::Bootstrap do

  subject { described_class.new(s3_uploader) }

  let(:s3_uploader) { double }

  let(:gem_files) do
    {
      'packaged-gem1' => '/path/to/cache/packaged-gem1.gem',
      'built-from-source-gem1' => '/path/to/cache/built-from-source-gem1.gem',
    }
  end

  describe "#build_and_upload_gems" do
    before do
      allow(Pipely::Bundler).to receive(:gem_files) { gem_files }
    end

    it 'uploads each gem' do
      expect(s3_uploader).to receive(:upload).with(gem_files.values)

      subject.build_and_upload_gems
    end
  end

  describe "#context" do
    let(:context) { subject.context(s3_steps_path) }
    let(:s3_steps_path) { 'a/test/path' }
    let(:s3_gem_paths) { double }

    before do
      allow(subject).to receive(:gem_files) { gem_files }

      allow(s3_uploader).to receive(:s3_urls).with(gem_files.values) do
        s3_gem_paths
      end
    end

    it "should have s3 steps path" do
      expect(context.s3_steps_path).to eq(s3_steps_path)
    end

    it "builds S3 urls to the uploaded gem files" do
      expect(context.gem_files).to eq(s3_gem_paths)
    end
  end
end
