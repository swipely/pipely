# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'
require 'pipely/deploy/bootstrap_registry'

describe Pipely::Deploy::BootstrapRegistry do

  subject { described_class.instance }

  describe "#mixins" do
    it "should default to empty" do
      expect(subject.mixins).to be_empty
    end
  end

  describe "#register_mixins" do
    context "with a mixin" do
      let(:mixin) { "Fixtures::BootstrapContexts::Green" }
      let(:result) { [mixin] }
      it "should registry mixin" do
        expect(subject.register_mixins(mixin)).to eql(result)
        expect(subject.mixins).to eql(result)
      end
    end

    context "when a mixin cannot be required" do
      it "should raise" do
        expect { subject.register_mixins('bad::mixin') }.to raise_error
      end
    end
  end
end
