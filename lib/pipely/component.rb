require 'virtus'
require 'pipely/reference_list'

module Pipely

  # Represents a Component within a Data Pipeline Definition
  # http://amzn.to/16lbBKx
  #
  class Component

    REFERENCE_KEYS = [
      'dependsOn',
      'input',
      'output',
      'runsOn',
      'schedule',
      'onFail',
      'onSuccess',
      'dataFormat',
    ]

    STATE_COLORS = {
      'FINISHED' => 'deepskyblue1',
      'RUNNING' => 'chartreuse',
      'WAITING_ON_DEPENDENCIES' => 'gray',
      'WAITING_FOR_RUNNER' => 'bisque4',
      'FAILED' => 'orangered',
    }

    include Virtus

    attribute :id, String
    attribute :type, String
    attribute :color, String
    attribute :execution_state, String

    attribute :dependsOn, ReferenceList
    attribute :input, ReferenceList
    attribute :output, ReferenceList
    attribute :runsOn, ReferenceList
    attribute :schedule, ReferenceList
    attribute :onFail, ReferenceList
    attribute :onSuccess, ReferenceList
    attribute :dataFormat, ReferenceList

    def initialize(args)
      @original_args = args.clone
      super
      coerce_references
    end

    def coerce_references
      REFERENCE_KEYS.each do |key|
        value = send(key)
        unless value.is_a?(ReferenceList)
          send("#{key}=", ReferenceList.new(value))
        end
      end
    end

    def graphviz_options
      {
        :shape => 'record',
        :label => "{#{label}}",
        :color => color || 'black',
        :fillcolor => STATE_COLORS[execution_state] || 'white',
        :style => 'filled',
      }
    end

    def dependencies(scope=nil)
      deps = dependsOn.build_dependencies('dependsOn') +
        input.build_dependencies('input') +
        output.build_dependencies('output')

      if :all == scope
        deps += runsOn.build_dependencies(:runsOn)
        deps += schedule.build_dependencies(:schedule)
        deps += onFail.build_dependencies(:onFail)
        deps += onSuccess.build_dependencies(:onSuccess)
        deps += dataFormat.build_dependencies(:dataFormat)
      end

      deps
    end

    def to_json(options={}, depth=0)
      h = @original_args

      REFERENCE_KEYS.each do |key|
        value = send(key)

        if value.present?
          h[key] = value
        else
          h.delete(key)
        end
      end

      h.to_json(options)
    end

  private

    def label
      [id, type, execution_state].compact.join('|')
    end

  end

end
