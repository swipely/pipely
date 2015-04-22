module Pipely
  module Build

    # Compute schedule attributes for a pipeline that runs once-a-day at a set
    # time.
    #
    class HourlyScheduler

      def period
        '1 hours'
      end

      def start_date_time

        (Time.now.utc + 3600).strftime("%Y-%m-%dT%H:00:00")

      end

      def to_hash
        {
          :period => period,
          :start_date_time => start_date_time
        }
      end

    end

  end
end
