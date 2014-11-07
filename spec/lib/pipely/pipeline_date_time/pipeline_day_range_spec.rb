# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_day_range'

describe Pipely::PipelineDateTime::PipelineDayRange do
  let(:target_date) { '@scheduledStartTime' }
  let(:days_back_start) { 2 }
  let(:days_back_end) { 0 }
  subject { described_class.new(target_date, days_back_start, days_back_end) }

  describe '#days' do
    let(:expected_days) do
      [
        "\#{format(@scheduledStartTime, \"YYYY/MM/dd\")}",
        "\#{format(minusDays(@scheduledStartTime, 1), \"YYYY/MM/dd\")}",
        "\#{format(minusDays(@scheduledStartTime, 2), \"YYYY/MM/dd\")}"
      ]
    end

    it 'returns the expect value' do
      expect(subject.days).to eq expected_days
    end
  end
end
