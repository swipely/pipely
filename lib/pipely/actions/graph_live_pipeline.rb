module Pipely
  module Actions

    # Graph a deployed pipeline with live execution statuses.
    #
    class GraphLivePipeline

      def initialize(options)
        @options = options
      end

      def execute
        live_pipeline = Pipely::LivePipeline.new(@options.pipeline_id)
        live_pipeline.print_runs_report

        outfile = live_pipeline.render_graphs(@options.output_path)

        if @options.json_output
          $stdout.puts({ :graph => outfile }.to_json)
        elsif $stdout.tty?
          $stdout.puts "Generated #{outfile}"
        else
          $stdout.puts outfile
        end
      end

    end

  end
end
