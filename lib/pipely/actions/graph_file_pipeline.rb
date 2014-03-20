module Pipely
  module Actions

    # Graph a pipeline definition from a file.
    #
    class GraphFilePipeline

      def initialize(options)
        @options = options
      end

      def execute
        puts "Generating #{output_file}"
        Pipely.draw(definition_json, output_file)
      end

    private

      def definition_json
        File.open(@options.input_path).read
      end

      def output_base
        @output_base ||= File.basename(@options.input_path,".*") + '.png'
      end

      def output_file
        @output_file ||= if @options.output_path
          File.join(@options.output_path, output_base)
        else
          output_base
        end
      end

    end

  end
end

