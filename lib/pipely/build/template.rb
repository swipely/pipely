require 'active_support/core_ext/hash'
require 'erb'

require 'pipely/build/template_helpers'

module Pipely
  module Build

    # An ERB template that can be interpolated with config hashes to render a
    # deployable pipeline definition.
    #
    class Template
      include TemplateHelpers

      attr_accessor :pipeline_id

      def initialize(source)
        @source = source
        @config = {}
      end

      def apply_config(attributes)
        @config.merge!(attributes.symbolize_keys)
      end

      def to_json
        ERB.new(@source).result(binding)
      end

      def respond_to_missing(method_name, include_private=false)
        @config.keys.include?(method_name.to_s) || super
      end

      def method_missing(method_name, *args, &block)
        if @config.keys.include?(method_name)
          @config[method_name]
        else
          super
        end
      end

    end

  end
end
