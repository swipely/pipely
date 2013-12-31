module Pipely
  module Build

    # Compute schedule attributes for a pipeline that should run immediately
    # after being deployed.
    #
    class RightNowScheduler

      def period
        '12 hours'
      end

      def start_date_time
        Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S")
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
