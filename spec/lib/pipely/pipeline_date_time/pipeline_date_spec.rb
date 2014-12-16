# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date'

describe Pipely::PipelineDateTime::PipelineDate do
  let(:target_date) { '@scheduledStartTime' }

  context 'with default time formats' do
    context 'with positive num days back' do
      let(:num_days_back) { 5 }
      subject { described_class.new(target_date, num_days_back) }

      describe '#day' do
        let(:result) do
          "\#{format(minusDays(@scheduledStartTime, 5), \"YYYY/MM/dd\")}"
        end

        it { expect(subject.day).to eq(result) }
      end

      describe '#month' do
        let(:result) do
          "\#{format(minusDays(@scheduledStartTime, 5), \"YYYY/MM\")}/[0-9]+"
        end

        it { expect(subject.month).to eq(result) }
      end

      describe '#year' do
        let(:result) do
          "\#{format(minusDays(@scheduledStartTime, 5), "\
            "\"YYYY\")}/[0-9]+/[0-9]+"
        end

        it { expect(subject.year).to eq(result) }
      end
    end

    context 'with 0 days back' do
      let(:num_days_back) { 0 }
      subject { described_class.new(target_date, num_days_back) }

      describe '#day' do
        let(:result) do
          "\#{format(@scheduledStartTime, \"YYYY/MM/dd\")}"
        end

        it { expect(subject.day).to eq(result) }
      end
    end

    context 'with negative num days back' do
      let(:num_days_back) { -3 }
      subject { described_class.new(target_date, num_days_back) }

      describe '#day' do
        let(:result) do
          "\#{format(plusDays(@scheduledStartTime, 3), \"YYYY/MM/dd\")}"
        end

        it { expect(subject.day).to eq(result) }
      end
    end
  end

  context 'with custom date time formats' do
    let(:day_format) { 'DAY_FORMAT' }
    let(:month_format) { 'MONTH_FORMAT' }
    let(:year_format) { 'YEAR_FORMAT' }

    before do
      described_class.day_format = day_format
      described_class.month_format = month_format
      described_class.year_format = year_format
    end

    after do
      described_class.day_format = described_class::DEFAULT_DAY_FORMAT
      described_class.month_format = described_class::DEFAULT_MONTH_FORMAT
      described_class.year_format = described_class::DEFAULT_YEAR_FORMAT
    end

    context 'with negative num days back' do
      let(:num_days_back) { -3 }
      subject { described_class.new(target_date, num_days_back) }

      describe '#day' do
        let(:result) do
          "\#{format(plusDays(@scheduledStartTime, 3), \"#{day_format}\")}"
        end

        it { expect(subject.day).to eq(result) }
      end

      describe '#month' do
        let(:result) do
          "\#{format(plusDays(@scheduledStartTime, 3), "\
            "\"#{month_format}\")}/[0-9]+"
        end

        it { expect(subject.month).to eq(result) }
      end

      describe '#year' do
        let(:result) do
          "\#{format(plusDays(@scheduledStartTime, 3), "\
            "\"#{year_format}\")}/[0-9]+/[0-9]+"
        end

        it { expect(subject.year).to eq(result) }
      end
    end
  end
end
