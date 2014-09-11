# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap_context'
require 'fileutils'

describe Pipely::Deploy::BootstrapContext do
  subject { Pipely::Deploy::BootstrapContext.new(['one.gem', 'two.gem']) }

  describe "#install_gems_script" do
    it "defaults to hadoop fs" do
      expect(subject.install_gems_script).to eql "
# one.gem
hadoop fs -copyToLocal one.gem one.gem
gem install --local one.gem --no-ri --no-rdoc

# two.gem
hadoop fs -copyToLocal two.gem two.gem
gem install --local two.gem --no-ri --no-rdoc
"
    end

    context "with aws cli" do
      it "should build script for aws cli" do
        expect(subject.install_gems_script(:awscli) ).to eql "
# one.gem
aws s3 cp one.gem one.gem
gem install --local one.gem --no-ri --no-rdoc

# two.gem
aws s3 cp two.gem two.gem
gem install --local two.gem --no-ri --no-rdoc
"
      end
    end

    context "with yield" do
      it "should build script for aws cli" do
        expect(subject.install_gems_script(:awscli) do |gem_file, filename, command|
          "custom command - #{gem_file} #{filename} #{command}"
        end).to eql "
# one.gem
custom command - one.gem one.gem aws s3 cp one.gem one.gem
gem install --local one.gem --no-ri --no-rdoc

# two.gem
custom command - two.gem two.gem aws s3 cp two.gem two.gem
gem install --local two.gem --no-ri --no-rdoc
"
      end
    end
  end
end
