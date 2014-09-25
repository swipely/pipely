require 'pipely/bundler/gem_packager'

describe Pipely::Bundler::GemPackager do

  describe "#package" do
    context "with a cache file" do
      it "should return the cache file" do
        spec = double("spec", name: 'test', cache_file: 'a/cache/file')
        expect(File).to receive(:exists?).with('a/cache/file').and_return(true)
        expect(subject.package(spec)).to eq({"test"=>"a/cache/file"})
      end
    end

    context "without a cache file" do
      it "should build the gem" do
        spec = double("spec",
          name: 'test', cache_file: 'a/cache/file', gem_dir:'a/gem/dir')
        expect(File).to receive(:exists?).with('a/cache/file').and_return(false)
        expect(subject).to receive(:build_from_source).and_return(
          {"test"=>"a/packaged/file"})
        expect(subject.package(spec)).to eq({"test"=>"a/packaged/file"})
      end
    end
  end

  describe "#build_from_source" do
    context "with bad spec" do
      it "should raise" do
        expect { subject.build_from_source("bad-name", ".") }.to raise_error
      end
    end
  end

end
