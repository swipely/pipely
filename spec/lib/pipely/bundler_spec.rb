require 'pipely/bundler'

describe Pipely::Bundler do
  subject { described_class }
  let(:gem_names) do
     %w[
      activesupport aws-sdk aws-sdk-v1 axiom-types builder
      bundler coercible descendants_tracker equalizer erubis
      excon fog fog-brightbox fog-core fog-json
      fog-softlayer formatador i18n ice_nine inflecto
      ipaddress json mime-types mini_portile minitest
      multi_json net-scp net-ssh nokogiri pipely rake
      ruby-graphviz thread_safe tzinfo unf unf_ext uuidtools
      virtus
    ]
  end

  describe ".gem_names" do
    it "should have names" do
      expect(subject.gem_names.sort).to eql gem_names
    end
  end

  describe ".locked_sources" do
    it "should have sources" do
      expect(subject.locked_sources.map(&:name).sort).to eql [
        "pipely"
      ]
    end
  end

  describe ".packaged_gems" do
    it "should haves gems" do
      expect(subject.packaged_gems.keys.sort).to eql(gem_names - ["pipely"])
    end

    context "with filtering" do
      it "should have gems" do
        gems = subject.packaged_gems do |specs|
          specs.reject { |s| s.name == "bundler" }
        end.keys.sort
        expect(gems).to eql(gem_names - ["pipely", "bundler"])
      end
    end
  end

  describe ".package_gem" do
    context "with a cache file" do
      it "should return the cache file" do
        spec = double("spec", name: 'test', cache_file: 'a/cache/file')
        expect(File).to receive(:exists?).with('a/cache/file').and_return(true)
        expect(subject.package_gem(spec)).to eql({"test"=>"a/cache/file"})
      end
    end

    context "without a cache file" do
      it "should build the gem" do
        spec = double("spec",
          name: 'test', cache_file: 'a/cache/file', gem_dir:'a/gem/dir')
        expect(File).to receive(:exists?).with('a/cache/file').and_return(false)
        expect(subject).to receive(:build_gem).and_return(
          {"test"=>"a/packaged/file"})
        expect(subject.package_gem(spec)).to eql({"test"=>"a/packaged/file"})
      end
    end
  end

  describe ".build_gems_from_source" do
    it "should build gem from source" do
      expect(subject).to receive(:build_gem).with(
        "pipely", Pathname.new(".")).and_return({"pipely" => "./file.gem"})
      expect(subject.build_gems_from_source).to eql({
        "pipely" => "./file.gem"
      })
    end
  end

  describe ".build_gem" do
    context "with bad spec" do
      it "should raise" do
        expect { subject.build_gem("bad-name", ".") }.to raise_error
      end
    end
  end
end
