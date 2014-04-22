require_relative '../configure_aws'
require 'aws-sdk'
require 'singleton'

module Pipely

  module Emr

    class Api
      include Pipely::ConfigureAws
      include Singleton

      attr_accessor :client

      def initialize
        super()

        configure

        @client = AWS::EMR.new.client
      end
    end

  end

end
