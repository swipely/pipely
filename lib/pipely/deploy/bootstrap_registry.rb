require 'singleton'

module Pipely
  module Deploy

    #
    ## Registry of Mixins to be applied to the bootstrap context
    #
    class BootstrapRegistry
      include Singleton

      def initialize
        @mixins = []
      end

      def register_mixins(*mixins)
        new_mixins = [mixins].flatten.compact

        new_mixins.each do |mixin|
          begin
            require mixin.underscore
          rescue LoadError => e
            raise "Failed to require #{mixin} for bootstrap_contexts: #{e}"
          end
        end
        @mixins = (@mixins + new_mixins).uniq
      end

      def mixins
        @mixins
      end
    end
  end
end
