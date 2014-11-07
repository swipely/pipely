# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date'

module Pipely
  module PipelineDateTime
    # Base class for pipeline date ranges
    #
    class PipelineDateRangeBase
      attr_reader :days_back

      def initialize(target_date, days_back_start, days_back_end)
        @target_date = target_date
        @days_back_start = days_back_start
        @days_back_end = days_back_end
        @days_back = (days_back_end..days_back_start).to_set
      end

      def start
        @days_back_start
      end

      def end
        @days_back_end
      end

      def exclude(days_back_start, days_back_end)
        return if days_back_start < 0
        return if days_back_end < 0
        return if days_back_start < days_back_end  # Back smaller for earlier
        (days_back_end..days_back_start).each do |days_back|
          @days_back.delete days_back
        end
      end

      private

      def pipeline_dates
        @pipeline_dates ||= @days_back.map do |days_back|
          PipelineDate.new(@target_date, days_back)
        end
      end
    end
  end
end
