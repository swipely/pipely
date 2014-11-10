# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date_range_base'

module Pipely
  module PipelineDateTime
    # Class that represents a range of individual pipeline years
    #
    class PipelineYearRange < PipelineDateRangeBase
      DAYS_IN_YEAR = 365

      attr_reader :start, :end

      def initialize(target_date, days_back_start, days_back_end)
        @target_date = target_date
        @start = days_back_start - DAYS_IN_YEAR
        @end = days_back_end + DAYS_IN_YEAR
        @days_back = (@end..@start).step(DAYS_IN_YEAR).to_set
      end

      def years
        @years ||= pipeline_dates.map { |pd| pd.year }
      end
    end
  end
end
