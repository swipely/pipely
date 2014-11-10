# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_year_range'

describe Pipely::PipelineDateTime::PipelineYearRange do
  let(:target_date) { '@scheduledStartTime' }

  context 'with 729 days between start and end' do
    let(:days_back_start) { 729 }
    let(:days_back_end) { 0 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 364 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 365 }
    end

    describe '#years' do
      it { expect(subject.years).to eq [] }
    end
  end

  context 'with 730 days between start and end' do
    let(:days_back_start) { 731 }
    let(:days_back_end) { 1 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 366 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 366 }
    end

    describe '#years' do
      let(:expected_years) do
        ["\#{format(minusDays(@scheduledStartTime, 366), \"YYYY\")}"]
      end

      it { expect(subject.years).to eq expected_years }
    end
  end

  context 'with 1094 days between start and end' do
    let(:days_back_start) { 1096 }
    let(:days_back_end) { 2 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 731 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 367 }
    end

    describe '#years' do
      let(:expected_years) do
        ["\#{format(minusDays(@scheduledStartTime, 367), \"YYYY\")}"]
      end

      it { expect(subject.years).to eq expected_years }
    end
  end

  context 'with 1095 days between start and end' do
    let(:days_back_start) { 1098 }
    let(:days_back_end) { 3 }
    subject { described_class.new(target_date, days_back_start, days_back_end) }

    describe '#start' do
      it { expect(subject.start).to eq 733 }
    end

    describe '#end' do
      it { expect(subject.end).to eq 368 }
    end

    describe '#years' do
      let(:expected_years) do
        [
          "\#{format(minusDays(@scheduledStartTime, 368), \"YYYY\")}",
          "\#{format(minusDays(@scheduledStartTime, 733), \"YYYY\")}"
        ]
      end

      it { expect(subject.years).to eq expected_years }
    end
  end
end
