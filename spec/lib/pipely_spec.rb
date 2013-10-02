require 'pipely'

describe Pipely do
  let(:definition_json) { stub }
  let(:filename) { stub }
  let(:definition) { stub }

  before do
    Pipely::Definition.stub(:parse).with(definition_json) { definition }
  end

  describe '.draw' do
    let(:components) { stub }
    let(:definition) { stub(:definition, :components_for_graph => components) }
    let(:graph) { stub(:graph, :output => nil) }

    before do
      Pipely::GraphBuilder.any_instance.stub(:build).with(components) { graph }
    end

    it 'parses a JSON definition and builds a graph' do
      graph.should_receive(:output).with(:png => filename)

      described_class.draw(definition_json, filename)
    end

    context 'with node_attributes' do
      let(:node_attributes) { stub }

      it 'applies the node_attributes to the definition' do
        definition.should_receive(:apply_node_attributes).with(node_attributes)

        described_class.draw(definition_json, filename, node_attributes)
      end
    end
  end

end
