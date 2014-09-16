# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap'
require 'fileutils'

describe Pipely::Deploy::Bootstrap do
  subject { described_class.new(s3_bucket, 'test_path/gems') }
  let(:s3_bucket) do
     s3 = AWS::S3.new
     s3.buckets['a-test-bucket']
  end

  let(:bundled_gems) { subject.gems_from_bundler }
  let(:build_and_upload_gems) do
    objects = double(:objects)
    s3_object = double('s3_object', write: nil, exists?: true)

    allow(objects).to receive(:[]) { s3_object }

    gems = bundled_gems.each do |name, gem|
      expect(objects).to receive(:[]).with(subject.gem_s3_path(gem))
    end

    expect(s3_bucket).to(receive(:objects)).
      exactly(gems.size + 1).times. # pipeline gem + deps
      and_return(objects)

    subject.build_and_upload_gems
  end

  it "should have bucket name" do
    expect(subject.bucket_name).to eql 'a-test-bucket'
  end

  it "should have a s3 gems path" do
    expect(subject.s3_gems_path).to eql 'test_path/gems'
  end

  describe "#gems_from_bundler" do
    it "should have a hash of gems" do
      gem_names = subject.gems_from_bundler.keys.reject do |g|
        g == 'bundler'
      end.sort

      expect(gem_names).to eql(
        %w[activesupport aws-sdk aws-sdk-v1 axiom-types builder
           coercible descendants_tracker equalizer erubis excon fog
           fog-brightbox fog-core fog-json fog-softlayer formatador
           i18n ice_nine inflecto ipaddress json mime-types mini_portile
           minitest multi_json net-scp net-ssh nokogiri rake
           ruby-graphviz thread_safe tzinfo unf unf_ext uuidtools
           virtus]
      )
    end
  end

  describe "#build_and_upload_gems" do
    before do
      build_and_upload_gems
    end

    it "should create project gem" do
      expect(File).to exist(subject.project_spec.file_name)
    end
  end

  describe "#context" do
    let(:context) { subject.context }

    before do
      build_and_upload_gems
    end

    it "should have gem_files" do
      expect(context.gem_files).to_not be_nil
    end

    it "should be an s3 url" do
      reg =
        /^s3:\/\/#{subject.bucket_name}\/#{subject.s3_gems_path}/
      expect(context.gem_files.first).to match(reg)
    end
  end
end
