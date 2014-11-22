# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_month_range'

describe Pipely::PipelineDateTime::PipelineMonthRange do
  let(:target_date) { '@scheduledStartTime' }

  context 'with 59 days between start and end' do
    let(:days_back_start) { 59 }
    let(:days_back_end) { 0 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 29 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 30 }
    end

    describe '#months' do
      it { expect(subject.months).to eq [] }
    end
  end

  context 'with 60 days between start and end' do
    let(:days_back_start) { 62 }
    let(:days_back_end) { 2 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 32 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 32 }
    end

    describe '#months' do
      let(:expected_months) do
        ["\#{format(minusDays(@scheduledStartTime, 32), \"YYYY/MM\")}/[0-9]+"]
      end

      it { expect(subject.months).to eq expected_months }
    end
  end

  context 'with 87 days between start and end' do
    let(:days_back_start) { 90 }
    let(:days_back_end) { 3 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 60 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 33 }
    end

    describe '#months' do
      let(:expected_months) do
        ["\#{format(minusDays(@scheduledStartTime, 33), \"YYYY/MM\")}/[0-9]+"]
      end

      it { expect(subject.months).to eq expected_months }
    end
  end

  context 'with 88 days between start and end' do
    let(:days_back_start) { 92 }
    let(:days_back_end) { 4 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 62 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 34 }
    end

    describe '#months' do
      let(:expected_months) do
        [
          "\#{format(minusDays(@scheduledStartTime, 34), \"YYYY/MM\")}/[0-9]+",
          "\#{format(minusDays(@scheduledStartTime, 62), \"YYYY/MM\")}/[0-9]+"
        ]
      end

      it { expect(subject.months).to eq expected_months }
    end
  end
end
