require 'optparse'

module Pipely

  # Options for running the CLI
  #
  class Options

    attr_accessor :pipeline_id, :input_path, :output_path,
      :verbose, :automatic_open, :json_output, :latest_run,
      :object_id, :list_log_paths

    def self.parse
      options = Pipely::Options.new

      OptionParser.new do |opts|
        opts.banner = "Usage: pipely [options]"

        opts.on("-p", "--pipeline-id PIPELINE_ID",
          "ID of a live pipeline to visualize with live statuses") do |id|
          options.pipeline_id = id
        end

        opts.on("-l", "--latest", "Graph only the latest run") do |latest|
          options.latest_run = latest
        end

        opts.on("-i", "--input PATH",
          "Path to a JSON pipeline definition file to visualize") do |input|
          options.input_path = input
        end

        opts.on("-o", "--output PATH",
          "Local or S3 path to write Graphviz PNG file(s)") do |output|
          options.output_path = output
        end

        opts.on("-j", "--json", "Write STDOUT formatted as JSON") do |json|
          options.json_output = json
        end

        opts.on("-s", "--logs [OBJECT_ID]",
          "Print s3 log paths for an object") do |obj_id|
          options.object_id = obj_id
          options.list_log_paths = true
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

      end.parse!

      options
    end

  end

end
