# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap_context'
require 'fileutils'

describe Pipely::Deploy::BootstrapContext do
  subject do
    Pipely::Deploy::BootstrapContext.new.tap do |context|
      context.gem_files = ['one.gem', 'two.gem']
    end
  end

  describe "#install_gems_script" do
    it "defaults to hadoop fs" do
      expect(subject.install_gems_script).to eql "
# one.gem
hadoop fs -copyToLocal one.gem one.gem
gem install --force --local one.gem --no-ri --no-rdoc

# two.gem
hadoop fs -copyToLocal two.gem two.gem
gem install --force --local two.gem --no-ri --no-rdoc
"
    end

    context "with aws cli" do
      it "should build script for aws cli" do
        expect(subject.install_gems_script(:awscli) ).to eql "
# one.gem
aws s3 cp one.gem one.gem
gem install --force --local one.gem --no-ri --no-rdoc

# two.gem
aws s3 cp two.gem two.gem
gem install --force --local two.gem --no-ri --no-rdoc
"
      end
    end

    context "with yield" do
      it "should build script for aws cli" do
        expect(subject.install_gems_script(:awscli) do |command,file,filename|
          "custom command - #{file} #{filename} #{command}"
        end).to eql "
# one.gem
custom command - one.gem one.gem aws s3 cp
gem install --force --local one.gem --no-ri --no-rdoc

# two.gem
custom command - two.gem two.gem aws s3 cp
gem install --force --local two.gem --no-ri --no-rdoc
"
      end
    end
  end
end
