module Pipely
  module Build

    # Helper methods used by ERB templates.
    #
    module TemplateHelpers

      def s3_asset_path(path)
        "#{s3_asset_prefix if '/' == path[0]}#{path}"
      end

      def s3n_asset_path(path)
        "#{s3n_asset_prefix if '/' == path[0]}#{path}"
      end

      def s3n_step_path(path)
        "#{s3n_step_prefix if '/' == path[0]}#{path}"
      end

      # Renders command for a streaming Hadoop step
      #
      class StreamingHadoopStep

        def initialize
          @parts = [ '/home/hadoop/contrib/streaming/hadoop-streaming.jar' ]

          yield self if block_given?
        end

        def apply_part(key, values)
          values.each do |value|
            @parts += [key, value]
          end
        end

        def to_s
          @parts.join(',')
        end

      end

      def s3n_asset_paths(paths)
        Array(paths).map { |p| s3n_asset_path(p) }
      end

      def s3_asset_paths(paths)
        Array(paths).map { |p| s3_asset_path(p) }
      end

      def s3n_step_paths(paths)
        Array(paths).map { |p| s3n_step_path(p) }
      end

      def env_vars(options)
        return [] unless options
        options.map { |k, v| "#{ k }=#{ v }" }
      end

      def streaming_hadoop_step(options)
        StreamingHadoopStep.new do |s|
          s.apply_part('-libjars', Array(options[:lib_jars]))
          s.apply_part('-D', env_vars(options[:defs]))
          s.apply_part('-input', s3n_asset_paths(options[:input]))
          s.apply_part('-output', s3_asset_paths(options[:output]))
          s.apply_part('-mapper', s3n_step_paths(options[:mapper]))
          s.apply_part('-reducer', s3n_step_paths(options[:reducer]))
          s.apply_part('-cacheFile', s3n_asset_paths(options[:cache_file]))
          s.apply_part('-cmdenv', env_vars(options[:env]))
        end.to_s
      end

    end

  end
end
