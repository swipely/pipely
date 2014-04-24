require_relative '../configure_aws'
require 'aws-sdk'
require 'singleton'

module Pipely

  module DataPipeline

    class Api
      include Pipely::ConfigureAws
      include Singleton

      attr_accessor :client

      def initialize
        super()

        configure

        @client = AWS::DataPipeline.new.client
      end

    end

  end

end
