require 'pipely/dependency'

module Pipely

  # A list of references to Components for managing dependencies
  #
  class ReferenceList

    def initialize(input)
      @raw_references = [input].flatten.compact
    end

    def build_dependencies(label)
      @raw_references.map{|h| Dependency.new(label, h['ref'])}
    end

    def to_json(options={}, depth=0)
      if 1 == @raw_references.count
        @raw_references.first.to_json(options)
      else
        @raw_references.to_json(options)
      end
    end

    def present?
      !@raw_references.empty?
    end

  end

end

