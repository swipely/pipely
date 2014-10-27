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

      def streaming_hadoop_step(options)
        hadoop_step(
          '/home/hadoop/contrib/streaming/hadoop-streaming.jar',
          options
        )
      end

      def s3_dist_cp_hadoop_step(options)
        hadoop_step(
          '/home/hadoop/lib/emr-s3distcp-1.0.jar',
          options
        )
      end

      def hadoop_step(jar, options)
        parts = [ jar ]

        if jars = options[:lib_jars]
          parts += Array(jars).map { |jar| ['-libjars', "#{jar}"] }.flatten
        end

        (options[:defs] || {}).each do |name, value|
          parts += ['-D', "#{name}=#{value}".gsub(',', "\\,")]
        end

        Array(options[:input]).each do |input|
          parts += [ '-input', s3n_asset_path(input) ]
        end

        Array(options[:output]).each do |output|
          parts += ['-output', s3_asset_path(output) ]
        end

        if options[:outputformat]
          parts += ['-outputformat', options[:outputformat] ]
        end

        if options[:partitioner]
          parts += ['-partitioner', options[:partitioner] ]
        end

        Array(options[:mapper]).each do |mapper|
          parts += ['-mapper', s3n_step_path(mapper) ]
        end

        Array(options[:reducer]).each do |reducer|
          parts += ['-reducer', s3n_step_path(reducer) ]
        end

        Array(options[:cache_file]).each do |cache_file|
          parts += ['-cacheFile', s3n_asset_path(cache_file)]
        end

        (options[:env] || {}).each do |name, value|
          parts += ['-cmdenv', "#{name}=#{value}"]
        end

        parts.join(',')
      end

    end

  end
end
