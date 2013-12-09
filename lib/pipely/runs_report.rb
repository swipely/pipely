module Pipely

  # Prints a CLI report of the execution status of a live pipeline
  class RunsReport < Struct.new(:task_states_by_scheduled_start)

    def print
      return false unless $stdout.tty?

      task_states_by_scheduled_start.each do |scheduled_start, task_states|
        task_states.to_a.sort_by(&:first).each do |task_name, attributes|
          current_state = attributes[:execution_state]

          puts task_name.ljust(55) +
            "scheduled_start: #{scheduled_start}\t\t" +
            "current_state: #{current_state}"
        end
      end
    end

  end
end

