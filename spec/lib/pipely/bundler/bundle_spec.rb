require 'pipely/bundler/bundle'

describe Pipely::Bundler::Bundle do

  describe ".build" do
    let(:groups) { [ :group1 ] }
    let(:definition) { double "Bundler::Definition" }
    let(:spec_set) { double }

    before do
      definition.stub(:specs_for).with(groups) { spec_set }
    end

    it 'builds a Bundle instance with the spec_set' do
      bundle = described_class.build('vendor/test', groups, definition)
      expect(bundle.spec_set).to eq(spec_set)
    end
  end

  let(:pipely_spec) { double("Gem::Specification", name: "pipely") }
  let(:gem1_spec)   { double("Gem::Specification", name: "gem1")   }
  let(:gem2_spec)   { double("Gem::Specification", name: "gem2")   }

  let(:pipely_source) do
    Bundler::Source::Path.new('name' => "pipely", 'path' => '.')
  end

  let(:spec_set) { [ pipely_spec, gem1_spec, gem2_spec ] }
  let(:locked_sources) { [ pipely_source ] }

  subject { described_class.new('vendor/test', spec_set, locked_sources) }

  describe "#gem_files" do
    let(:gem_packager) { double }

    before do
      gem_packager.stub(:package).and_return do |spec|
        { spec.name => '/path/to/cache/file.gem' }
      end

      gem_packager.stub(:build_from_source).and_return do |name, path|
        { name => "#{path}/#{name}-X.Y.Z.gem" }
      end
    end

    it "returns a cache file for each gem" do
      gem_files = subject.gem_files(gem_packager: gem_packager)
      expect(gem_files.keys).to match_array(%w[ gem1 gem2 pipely ])
    end

    it "filters out gems to exclude" do
      gem_files = subject.gem_files(gem_packager: gem_packager,
                                    gems_to_exclude: ['gem2'])
      expect(gem_files.keys).to match_array(%w[ gem1 pipely ])
    end

    context "given a packaged/non-locked gem" do
      it "returns the gems and their existing cache files" do
        expect(gem_packager).to receive(:package).with(gem1_spec)
        expect(gem_packager).to receive(:package).with(gem2_spec)

        subject.gem_files(gem_packager: gem_packager)
      end
    end

    context "given a locked-source gem" do
      it "should build new cache files from source" do
        expect(gem_packager).to receive(:build_from_source).with(
          pipely_source.name,
          pipely_source.path
        )

        subject.gem_files(gem_packager: gem_packager)
      end
    end
  end

end
