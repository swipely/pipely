# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap'
require 'fog'
require 'fileutils'

module Pipely
  describe Deploy::Bootstrap do
    subject { Deploy::Bootstrap.new storage, 'test_bucket', 'test_path/gems' }
    let(:storage) { Fog::Storage.new provider: 'local', local_root: 'tmp'  }

    before do
      FileUtils.mkdir_p 'tmp/test_bucket'
    end

    it "should have bucket name" do
      expect(subject.bucket_name).to eql 'test_bucket'
    end

    it "should have a s3 gems path" do
      expect(subject.s3_gems_path).to eql 'test_path/gems'
    end

    describe "#build_and_upload_gems" do
      before do
        subject.build_and_upload_gems
      end

      it "should create project gem" do
        File.exists? subject.project_spec.file_name
      end

      it "should upload gems" do
        Bundler.definition.specs_for([:default]).each do |spec|
          # Ignore bundler, since it could be a system installed gem (travis) without a cache file
          unless spec.file_name =~ /bundler/
            expect(File).to exist(
              File.join "tmp/test_bucket/test_path/gems", spec.file_name )
          end
        end
      end
    end

    describe "#context" do
      let(:context) { subject.context}

      before do
        subject.build_and_upload_gems
      end

      it "should have gem_files" do
        expect(context.gem_files).to_not be_nil
      end

      it "should be an s3 url" do
        expect(context.gem_files.first).to match( /^s3:\/\/#{subject.bucket_name}\/#{subject.s3_gems_path}/ )
      end
    end

  end
end
