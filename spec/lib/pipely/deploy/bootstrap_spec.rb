# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap'
require 'fileutils'
require 'fixtures/bootstrap_contexts/simple'
require 'fixtures/bootstrap_contexts/green'

describe Pipely::Deploy::Bootstrap do

  subject { described_class.new(gem_files, s3_steps_path) }
  let(:s3_steps_path) { 'a/test/path' }
  let(:gem_files) do
    {
      'packaged-gem1' => '/path/to/cache/packaged-gem1.gem',
      'built-from-source-gem1' => '/path/to/cache/built-from-source-gem1.gem',
    }
  end

  describe "#context" do
    context "without any mixins" do
      let(:context) { subject.context }

      before do
      #  allow(subject).to receive(:gem_files) { gem_files }

      #  allow(s3_uploader).to receive(:s3_urls).with(gem_files.values) do
      #    s3_gem_paths
      #  end
      end

      it "should have s3 steps path" do
        expect(context.s3_steps_path).to eq(s3_steps_path)
      end

      it "builds S3 urls to the uploaded gem files" do
        expect(context.gem_files).to eq(gem_files)
      end
    end

    context "with one mixin" do
      let(:context) { subject.context( mixin.name ) }
      let(:mixin) { Fixtures::BootstrapContexts::Simple }

      it "should have Simple mixin method" do
        expect(context.simple).to eq("simple")
      end
    end

    context "with multiple mixins" do
      let(:context) { subject.context( mixins.map(&:name) ) }
      let(:mixins) do
        [Fixtures::BootstrapContexts::Simple,Fixtures::BootstrapContexts::Green]
      end

      it "should have simple mixin method" do
        expect(context.simple).to eq("simple")
      end

      it "should have green mixin method" do
        expect(context.green).to eq("green")
      end
    end
  end
end
