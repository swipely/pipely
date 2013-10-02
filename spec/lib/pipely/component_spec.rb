require 'pipely/component'
require 'pipely/dependency'

describe Pipely::Component do

  subject {
    described_class.new(
      id: 'my-component',
      type: 'OreoSalad',
      dependsOn: {'ref' => 'asdf'},
      input: {'ref' => 'infile'},
      output: {'ref' => 'outfile'},
      color: 'yellow',
      execution_state: 'WAITING_FOR_RUNNER',
    )
  }

  it 'coerces dependsOn into a ReferenceList' do
    expect(subject.dependsOn).to be_a(Pipely::ReferenceList)
  end

  describe '#graphviz_options' do
    it 'builds properties for graphviz node representing this component' do
      expect(subject.graphviz_options).to eq({
        :shape => 'record',
        :label => '{my-component|OreoSalad|WAITING_FOR_RUNNER}',
        :color => 'yellow',
        :fillcolor => 'bisque4',
        :style => 'filled',
      })
    end
  end

  describe '#dependencies' do
    it 'includes dependsOn edges' do
      expect(subject.dependencies).to eq([
        Pipely::Dependency.new('dependsOn', 'asdf'),
        Pipely::Dependency.new('input', 'infile'),
        Pipely::Dependency.new('output', 'outfile'),
      ])
    end
  end

end
