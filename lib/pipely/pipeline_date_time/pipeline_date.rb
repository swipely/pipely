# encoding: utf-8
module Pipely
  module PipelineDateTime
    # Encapsulates AWS pipeline date
    #
    class PipelineDate
      DEFAULT_DAY_FORMAT = 'YYYY/MM/dd'
      DEFAULT_MONTH_FORMAT = 'YYYY/MM'
      DEFAULT_YEAR_FORMAT = 'YYYY'

      class << self
        def day_format=(day_format)
          @day_format = day_format
        end

        def day_format
          @day_format || DEFAULT_DAY_FORMAT
        end

        def month_format=(month_format)
          @month_format = month_format
        end

        def month_format
          @month_format || DEFAULT_MONTH_FORMAT
        end

        def year_format=(year_format)
          @year_format = year_format
        end

        def year_format
          @year_format || DEFAULT_YEAR_FORMAT
        end
      end

      def initialize(target_date, days_back)
        days_back = days_back.to_i
        @date_expression = case
                           when days_back > 0
                             "minusDays(#{target_date}, #{days_back})"
                           when days_back == 0
                             target_date
                           else
                             "plusDays(#{target_date}, #{-days_back})"
                           end
      end

      def day
        "\#{format(#{@date_expression}, \"#{PipelineDate.day_format}\")}"
      end

      def month
        "\#{format(#{@date_expression}, \"#{PipelineDate.month_format}\")}"
      end

      def year
        "\#{format(#{@date_expression}, \"#{PipelineDate.year_format}\")}"
      end
    end
  end
end
