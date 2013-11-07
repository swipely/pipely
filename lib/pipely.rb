require 'pipely/definition'
require 'pipely/graph_builder'
require 'pipely/live_pipeline'

# The top-level module for this gem. It provides the recommended public
# interface for using Pipely to visualize and manipulate your Data Pipeline
# definitions.
#
module Pipely

  def self.draw(definition_json, filename, node_attributes=nil)
    definition = Definition.parse(definition_json)
    definition.apply_node_attributes(node_attributes) if node_attributes

    graph_builder = GraphBuilder.new

    graph = graph_builder.build(definition.components_for_graph)
    graph.output( :png => filename )
  end

end
