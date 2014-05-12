module Pipely
  module Build

    # Compute schedule attributes for a pipeline that should run immediately
    # after being deployed.
    #
    class RightNowScheduler

      def period
        # DataPipeline is soon releasing a run-once feature.
        # TODO: Switch to that when available.
        '1 year'
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
