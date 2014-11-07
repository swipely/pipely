# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date_range_base'

module Pipely
  module PipelineDateTime
    # Class that represents a range of individual pipeline months
    #
    class PipelineMonthRange < PipelineDateRangeBase
      MINIMUM_MONTH_OFFSET = 30  # The month of x+/-30 will never add extra days
      MONTH_INTERVAL = 28  # We never miss a month by taking every 28 days

      attr_reader :start, :end

      def initialize(target_date, days_back_start, days_back_end)
        @target_date = target_date
        @start = days_back_start - MINIMUM_MONTH_OFFSET
        @end = days_back_end + MINIMUM_MONTH_OFFSET
        @days_back = (@end..@start).step(MONTH_INTERVAL).to_set
      end

      def months
        @months ||= pipeline_dates.map { |pd| pd.month }
      end
    end
  end
end
