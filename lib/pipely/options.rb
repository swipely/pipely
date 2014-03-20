require 'optparse'

module Pipely

  # Options for running the CLI
  #
  class Options

    attr_accessor :pipeline_id, :input_path, :output_path,
      :verbose, :automatic_open

    def self.parse
      options = Pipely::Options.new

      OptionParser.new do |opts|
        opts.banner = "Usage: pipely [options]"

        opts.on("-p", "--pipeline-id PIPELINE_ID",
          "ID of a live pipeline to visualize with live statuses") do |id|
          options.pipeline_id = id
        end

        opts.on("-i", "--input PATH",
          "Path to a JSON pipeline definition file to visualize") do |input|
          options.input_path = input
        end

        opts.on("-o", "--output PATH",
          "Local or S3 path to write Graphviz PNG file(s)") do |output|
          options.output_path = output
        end
      end.parse!

      options
    end

  end

end
