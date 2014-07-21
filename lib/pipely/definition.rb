require 'json'
require 'pipely/component'

module Pipely

  # Pipely's representation of a Pipeline Definition for AWS Data Pipeline
  # http://amzn.to/1bpW8Ru
  #
  class Definition

    # Showing all component types leads to an unwieldy graph.
    # TODO: make this list configurable.
    NON_GRAPH_COMPONENT_TYPES = [
      'Schedule',
      'SnsAlarm',
      'Ec2Resource',
      'EmrCluster',
      'CSV',
      nil,
    ]

    def self.parse(content)
      objects = JSON.parse(content)['objects']
      components = objects.map{|obj| Component.new(obj)}

      new(components)
    end

    def initialize(components)
      @components = components
    end

    attr_reader :components

    def components_for_graph
      components.reject { |component|
        NON_GRAPH_COMPONENT_TYPES.include?(component['type'])
      }
    end

    def to_json
      { :objects => components }.to_json
    end

    def apply_component_attributes(component_attributes)
      self.components.each do |component|
        if attributes = component_attributes[component.id]
          component.attributes = attributes
        end
      end
    end

  private

    def get_components(target_component_ids)
      components.select { |component|
        target_component_ids.include?(component.id)
      }
    end

    def dependencies_of(selected_components)
      all_dependencies = selected_components.map { |component|
        component.dependencies(:all)
      }.flatten.uniq

      Set.new(get_components(all_dependencies.map(&:target_id)))
    end

  end

end
