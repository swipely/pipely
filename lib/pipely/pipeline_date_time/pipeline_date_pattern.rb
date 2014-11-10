# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_day_range'
require 'pipely/pipeline_date_time/pipeline_month_range'
require 'pipely/pipeline_date_time/pipeline_year_range'

module Pipely
  module PipelineDateTime
    # Mixin for constructing compact date pattern selections
    #
    module PipelineDatePattern
      def date_pattern
        selection.target_all_time ? '.*' : any_string(date_pattern_parts)
      end

      private

      def date_pattern_parts
        day_range.exclude(month_range.start, month_range.end)
        month_range.exclude(year_range.start, year_range.end)
        day_range.days + month_range.months + year_range.years
      end

      def day_range
        @day_range ||= PipelineDayRange.new(selection.target_date, num_days, 0)
      end

      def month_range
        @month_range ||= PipelineMonthRange.new(selection.target_date, num_days,
                                                0)
      end

      def year_range
        @year_range ||= PipelineYearRange.new(selection.target_date, num_days,
                                              0)
      end

      def num_days
        selection.num_days_back.to_i
      end
    end
  end
end
