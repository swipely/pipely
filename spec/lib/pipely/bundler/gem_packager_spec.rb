require 'fileutils'
require 'pipely/bundler/gem_packager'

describe Pipely::Bundler::GemPackager do

  subject { described_class.new(vendor_path) }
  let(:vendor_path) { 'vendor/test' }

  before(:each) {
    unless Dir.exists? vendor_path
      FileUtils.mkdir_p 'vendor/test'
    end
  }

  describe "#package" do
    let(:gem_spec) do
      double("spec",
        name: 'test',
        cache_file: 'a/cache/file',
        gem_dir:'a/gem/dir',
        version:'0.0.1'
      )
    end

    let(:vendored_gem) { "vendor/test/file" }

    context "with a cache file" do
      before do
        allow(File).to receive(:exists?).with(vendored_gem) { false }
        allow(File).to receive(:exists?).with(gem_spec.cache_file) { true }
        allow(FileUtils).to receive(:cp).with(
          gem_spec.cache_file, vendored_gem)
      end

      it "returns the cache file" do
        expect(subject.package(gem_spec)).to eq(
          {gem_spec.name => vendored_gem}
        )
      end
    end

    context "without a cache file" do
      before do
        allow(File).to receive(:exists?).with(gem_spec.cache_file) { false }
        allow(File).to receive(:exists?).with(vendored_gem) { false }
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

        it "downloads from rubygems" do
          remote_fetcher = double(:remote_fetcher)
          expect(Gem::RemoteFetcher).to receive(:new).and_return(remote_fetcher)
          expect(remote_fetcher).to receive(:fetch_path).
            with("https://rubygems.org/downloads/test-0.0.1.gem")
          expect(subject.package(gem_spec)).to eq(
            {"test"=>"vendor/test/test-0.0.1.gem"})
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
