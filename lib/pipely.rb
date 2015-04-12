require 'pipely/options'
require 'pipely/actions'
require 'pipely/definition'
require 'pipely/graph_builder'
require 'pipely/live_pipeline'
require 'pipely/s3_writer'

# The top-level module for this gem. It provides the recommended public
# interface for using Pipely to visualize and manipulate your Data Pipeline
# definitions.
#
module Pipely

  ENV['AWS_REGION'] ||= 'us-east-1'
  
  def self.draw(definition_json, filename, component_attributes=nil)
    definition = Definition.parse(definition_json)

    if component_attributes
      definition.apply_component_attributes(component_attributes)
    end

    graph_builder = GraphBuilder.new

    graph = graph_builder.build(definition.components_for_graph)

    if filename.start_with?('s3://')
      content = graph.output( :png => String )
      S3Writer.new(filename).write(content)
    else
      graph.output( :png => filename )
      filename
    end
  end

end
