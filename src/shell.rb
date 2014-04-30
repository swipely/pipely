# src/shell.rb

require 'oyster'
require 'pry'

module Pipely
  class Shell
    BIN_SPEC = Oyster.spec do
      string :id
    end

    attr_reader :id

    def initialize(argv, io)
      @options = BIN_SPEC.parse(argv)
      @stdout  = io
      @id = @options[:id]

      welcome
    end

    def interpret(command)
      @stdout.puts command
    end

    def welcome
      warning = "You can specify a pipeline id with '--id [pipeline_id'" if !@id
      @stdout.puts "------------\nPipely Shell\n------------\n#{warning}"
    end
  end
end
