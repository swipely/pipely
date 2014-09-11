# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap'
require 'fog'
require 'fileutils'

module Pipely
  describe Deploy::Bootstrap do
    subject { described_class.new(s3_bucket, 'test_path/gems') }
    let(:s3_bucket) do
       s3 = AWS::S3.new
       s3.buckets['a-test-bucket']
    end

    it "should have bucket name" do
      expect(subject.bucket_name).to eql 'a-test-bucket'
    end

    it "should have a s3 gems path" do
      expect(subject.s3_gems_path).to eql 'test_path/gems'
    end

    describe "#build_and_upload_gems" do
      let(:build_and_upload_gems) do
        VCR.use_cassette('build_and_upload_gems') do
          subject.build_and_upload_gems
        end
      end

      it "should create project gem" do
        build_and_upload_gems

        expect(File).to exist(subject.project_spec.file_name)
      end

      it "should upload gems" do
        specs = Bundler.definition.specs_for([:default])

        gems = specs.map(&:file_name).reject do |g|
          # Ignore bundler, since it could be a system installed gem (travis)
          # without a cache file
          g.match(/^json-\d+\.\d+\.\d+\.gem$/) or
            g.match(/^bundler-\d+\.\d+\.\d+\.gem$/)
        end

        objects = double(:objects)
        s3_object = double('s3_object', write: nil)

        allow(objects).to receive(:[]) { s3_object }

        gems.each do |gem|
          expect(objects).to receive(:[]).with(subject.gem_s3_path(gem))
        end

        expect(s3_bucket).to(receive(:objects)).
          at_least(gems.size).times.
          at_most(gems.size + 1).times. # allow for Bundler
          and_return(objects)

        build_and_upload_gems
      end
    end

    describe "#context" do
      let(:context) { subject.context}

      before do
        VCR.use_cassette('build_and_upload_gems') do
          subject.build_and_upload_gems
        end
      end

      it "should have gem_files" do
        expect(context.gem_files).to_not be_nil
      end

      it "should be an s3 url" do
        expect(context.gem_files.first).to(
          match( /^s3:\/\/#{subject.bucket_name}\/#{subject.s3_gems_path}/ )
        )
      end
    end

  end
end
