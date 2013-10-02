require 'pipely/reference_list'

describe Pipely::ReferenceList do

  context 'given nil input' do
    subject { described_class.new(nil) }

    describe '#build_dependencies' do
      it 'returns an empty array' do
        expect(subject.build_dependencies('dependsOn')).to eq([])
      end
    end
  end

  context 'given a single input' do
    subject { described_class.new({ 'ref' => 'foo' }) }

    describe '#build_dependencies' do
      it 'returns an array of the single reference' do
        expect(subject.build_dependencies('dependsOn')).to eq([
          Pipely::Dependency.new('dependsOn', 'foo'),
        ])
      end
    end
  end

  context 'given an array of references as input' do
    subject {
      described_class.new([
        { 'ref' => 'foo' },
        { 'ref' => 'bar' },
      ])
    }

    describe '#build_dependencies' do
      it 'returns an array of the single reference' do
        expect(subject.build_dependencies('dependsOn')).to eq([
          Pipely::Dependency.new('dependsOn', 'foo'),
          Pipely::Dependency.new('dependsOn', 'bar'),
        ])
      end
    end
  end

end
