require 'pipely/definition'

describe Pipely::Definition do

  subject { described_class.parse(definition_json) }

  let(:definition_json) {
   <<EOF
      {
        "objects": [
          {
            "id": "DoStuff",
            "type": "ShellCommandActivity",
            "onFail": { "ref": "FailureNotify" }
          },
          {
            "id": "FailureNotify",
            "type": "SnsAlarm"
          }
        ]
      }
EOF
  }

  describe '#components' do
    it 'builds a Component for each object in the definition JSON' do
      expect(subject.components.count).to eq(2)
    end
  end

  describe '#components_for_graph' do
    it 'filters out node types we do not want on the graph' do
      expect(subject.components_for_graph.count).to eq(1)
    end
  end

  describe '#to_json' do
    it 'renders the components as JSON' do
      original = JSON.parse(definition_json)
      expect(JSON.parse(subject.to_json)).to eq(original)
    end
  end

  describe '#apply_component_attributes' do
    it 'applies attributes to nodes with matching ids' do
      subject.apply_component_attributes({
        'DoStuff' => { color: 'pink' },
      })

      pink_node = subject.components.detect{|n| n.id == 'DoStuff'}

      expect(pink_node.color).to eq('pink')
    end
  end

end
