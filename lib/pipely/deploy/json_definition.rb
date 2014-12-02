require 'json'

module Pipely
  module Deploy

    # The JSON definition format expected by the CLI differs from the structure
    # expected by the API.  This class transforms a CLI-ready definition into
    # the pipeline object hashes expected by the API.
    #
    class JSONDefinition
      def self.parse(definition)
        definition_objects = JSON.parse(definition)['objects']
        definition_objects.map { |object| new(object).to_api }
      end

      def initialize(object)
        @json_fields = object.clone
        @id = @json_fields.delete('id')
        @name = @json_fields.delete('name') || @id
      end

      def to_api
        {
          'id' => @id,
          'name' => @name,
          'fields' => fields
        }
      end

      private

      def fields
        @json_fields.map{|k,v| field_for_kv(k,v)}.flatten
      end

      def field_for_kv(key, value)
        if value.is_a?(Hash)
          { 'key' => key, 'refValue' => value['ref'] }

        elsif value.is_a?(Array)
          value.map { |subvalue| field_for_kv(key, subvalue) }

        else
          { 'key' => key, 'stringValue' => value }

        end
      end
    end

  end
end
