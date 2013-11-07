require 'json'
require 'graphviz'

module Pipely

  # Builds a GraphViz graph from a set of Components and their Dependencies
  class GraphBuilder

    def initialize(graph=nil)
      @graph = graph || GraphViz.new(:G, :type => :digraph)
    end

    def build(components)
      add_nodes(components)
      add_edges(components)
      @graph
    end

  private

    # Represent Components as nodes on the graph
    def add_nodes(components)
      components.each do |component|
        @graph.add_nodes(component.id, component.graphviz_options)
      end
    end

    # Represent Dependencies as edges on the graph
    def add_edges(components)
      components.each do |component|
        component.dependencies.each do |dependency|
          add_edge(component, dependency)
        end
      end
    end

    def add_edge(component, dependency)
      options = {
        :label => dependency.label,
        :color => dependency.color,
      }

      options[:dir] = 'back' if ('input' == dependency.label)

      if 'output' == dependency.label
        @graph.add_edges(
          dependency.target_id,
          component.id,
          options
        )
      else
        @graph.add_edges(
          component.id,
          dependency.target_id,
          options
        )
      end
    end

  end

end

