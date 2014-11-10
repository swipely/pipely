# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date_range_base'

describe Pipely::PipelineDateTime::PipelineDateRangeBase do
  let(:target_date) { '@scheduledStartTime' }
  let(:days_back_start) { 5 }
  let(:days_back_end) { 0 }
  subject { described_class.new(target_date, days_back_start, days_back_end) }

  let(:expected_days_back) { (days_back_end..days_back_start).to_set }

  describe '#days_back' do
    it 'returns the expect value' do
      expect(subject.days_back).to eq expected_days_back
    end
  end

  describe '#exclude' do
    it 'does not exclude when days_back_start is negative' do
      subject.exclude(-1, 0)
      expect(subject.days_back).to eq expected_days_back
    end

    it 'does not exclude when days_back_end is negative' do
      subject.exclude(0, -2)
      expect(subject.days_back).to eq expected_days_back
    end

    it 'does not exclude when days_back_start is smaller than days_back_end' do
      subject.exclude(3, 5)
      expect(subject.days_back).to eq expected_days_back
    end

    it 'excludes expected offsets' do
      subject.exclude(4, 2)
      expect(subject.days_back).to eq Set.new([0,1,5])
    end
  end
end
