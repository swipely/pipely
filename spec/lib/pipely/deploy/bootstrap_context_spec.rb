# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap_context'

describe Pipely::Deploy::BootstrapContext do
  subject do
    Pipely::Deploy::BootstrapContext.new.tap do |context|
      context.gem_files = ['one.gem', 'two.gem']
    end
  end

  let(:aws_install_gems_script) do
"
# one.gem
aws s3 cp one.gem one.gem
gem install --force --local one.gem --no-ri --no-rdoc

# two.gem
aws s3 cp two.gem two.gem
gem install --force --local two.gem --no-ri --no-rdoc
"
  end

  let(:hadoop_install_gems_script) do
"
# one.gem
hadoop fs -copyToLocal one.gem one.gem
gem install --force --local one.gem --no-ri --no-rdoc

# two.gem
hadoop fs -copyToLocal two.gem two.gem
gem install --force --local two.gem --no-ri --no-rdoc
"
  end

  describe "#install_gems_script" do
    it "with hadoop fs" do
      expect(subject.install_gems_script(:hadoop_fs)).to eql(
        hadoop_install_gems_script)
    end

    context "with aws cli" do
      it "should build script for aws cli" do
        expect(subject.install_gems_script(:awscli) ).to eql(
          aws_install_gems_script)
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

    context "using the emr context" do
      describe "#install_gems_script" do
        it "build script using hadoop fs" do
          expect(subject.install_gems_script(:hadoop_fs)).to eql "
# one.gem
hadoop fs -copyToLocal one.gem one.gem
gem install --force --local one.gem --no-ri --no-rdoc

# two.gem
hadoop fs -copyToLocal two.gem two.gem
gem install --force --local two.gem --no-ri --no-rdoc
"
        end
      end
    end

    context "using the emr context" do
      let(:emr) { subject.emr }

      describe '#install_gems_script' do
        it 'should be same as parent hadoop install script' do
          expect(emr.install_gems_script).to eq(hadoop_install_gems_script)
        end
      end
    end

    context "using the ec2 context" do
      let(:ec2) { subject.ec2 }

      describe '#install_gems_script' do
        it 'should be same as parent aws install script' do
          expect(ec2.install_gems_script).to eq(aws_install_gems_script)
        end
      end

      describe "#as_root" do

        context "on first run" do
          it "should build script with ssh init" do
            expect(ec2.as_root { "Custom Script here" }).to eql "
# Set up ssh access
if [ ! -f ~/.ssh/id_rsa ]; then
  mkdir -p ~/.ssh
  ssh-keygen -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
fi

# Use ssh to bypass the sudo \"require tty\" setting
ssh -o \"StrictHostKeyChecking no\" -t -t ec2-user@localhost <<- EOF
  sudo su -;
Custom Script here
  # exit twice, once for su and once for ssh
  exit;
  exit;
EOF
"
          end
        end

        context "on consective runs" do
          it "should build script" do
            ec2.as_root { "First run" }

            expect(ec2.as_root { "Second run" }).to eql "
# Use ssh to bypass the sudo \"require tty\" setting
ssh -o \"StrictHostKeyChecking no\" -t -t ec2-user@localhost <<- EOF
  sudo su -;
Second run
  # exit twice, once for su and once for ssh
  exit;
  exit;
EOF
"
          end
        end
      end
    end
  end
end
