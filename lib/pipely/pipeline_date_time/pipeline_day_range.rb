# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date_range_base'

module Pipely
  module PipelineDateTime
    # Class that represents a range of individual pipeline days
    #
    class PipelineDayRange < PipelineDateRangeBase
      def days
        @days ||= pipeline_dates.map { |pd| pd.day }
      end
    end
  end
end
