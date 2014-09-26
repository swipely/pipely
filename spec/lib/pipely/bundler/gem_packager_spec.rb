require 'pipely/bundler/gem_packager'

describe Pipely::Bundler::GemPackager do

  describe "#package" do
    let(:gem_spec) do
      double("spec",
        name: 'test',
        cache_file: 'a/cache/file',
        gem_dir:'a/gem/dir'
      )
    end

    context "with a cache file" do
      before do
        allow(File).to receive(:exists?).with(gem_spec.cache_file) { true }
      end

      it "returns the cache file" do
        expect(subject.package(gem_spec)).to eq(
          {gem_spec.name => gem_spec.cache_file}
        )
      end
    end

    context "without a cache file" do
      before do
        allow(File).to receive(:exists?).with(gem_spec.cache_file) { false }
      end

      context "if source is available" do
        before do
          allow(File).to receive(:directory?).with(gem_spec.gem_dir) { true }
        end

        it "builds the gem from source" do
          expect(subject).to receive(:build_from_source).and_return(
            {"test"=>"a/packaged/file"})

          expect(subject.package(gem_spec)).to eq({"test"=>"a/packaged/file"})
        end
      end

      context "if source not available, e.g. json-1.8.1 built into Ruby 2.1" do
        before do
          allow(File).to receive(:directory?).with(gem_spec.gem_dir) { false }
        end

        it "returns an empty hash " do
          expect(subject.package(gem_spec)).to eq({})
        end
      end
    end
  end

  describe "#build_from_source" do
    context "with bad spec" do
      it "raises" do
        expect { subject.build_from_source("bad-name", ".") }.to raise_error
      end
    end
  end

end
