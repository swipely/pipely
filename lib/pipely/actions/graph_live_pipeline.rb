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
        live_pipeline.render_graphs(@options.output_path)
      end

    end

  end
end
