require 'pipely/graph_builder'

describe Pipely::GraphBuilder do

  let(:graph) { stub(:graph) }

  let(:node1) {
    Pipely::Component.new(
      :id => '1',
      :dependsOn => { 'ref' => '2' },
    )
  }

  let(:node2) {
    Pipely::Component.new(
      :id => '2',
    )
  }

  subject { described_class.new(graph) }

  describe '#build' do
    it 'builds a graph from a list of Components' do
      graph.should_receive(:add_nodes).
        with(node1.id, node1.graphviz_options).ordered

      graph.should_receive(:add_nodes).
        with(node2.id, node2.graphviz_options).ordered

      graph.should_receive(:add_edges).
        with(
          node1.id,
          node2.id,
          :label => 'dependsOn',
          :color => 'black',
        ).ordered

      subject.build([node1, node2])
    end
  end

end
