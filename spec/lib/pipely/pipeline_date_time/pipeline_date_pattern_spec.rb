# encoding: utf-8
require 'pipely/pipeline_date_time/pipeline_date_pattern'

TestSelection = Struct.new(:num_days_back, :target_date, :target_all_time)

class TestDatePatternMatcher
  attr_accessor :day_offsets, :month_offsets, :year_offsets

  PipelineDate = Pipely::PipelineDateTime::PipelineDate

  def initialize(date_pattern, target_date, sep)
    @day_offsets, @month_offsets, @year_offsets = [], [], []
    date_pattern.split(sep).each do |part|
      days, format = days_and_format(part, target_date)
      case format
      when PipelineDate::DEFAULT_YEAR_FORMAT then @year_offsets << days
      when PipelineDate::DEFAULT_MONTH_FORMAT then @month_offsets << days
      when PipelineDate::DEFAULT_DAY_FORMAT then @day_offsets << days
      end
    end
  end

  private

  def days_and_format(part, target_date)
    trimmed = part.gsub("\#{format(", '').gsub("\")}", '')
    days_expr, format = trimmed.split(", \"")
    if days_expr == target_date
      days = 0
    else
      days = days_expr.gsub("minusDays(#{target_date}, ", '').gsub(')', '')
    end
    return days.to_i, format
  end
end

class TestPipelineDatePattern
  include Pipely::PipelineDateTime::PipelineDatePattern

  attr_reader :selection

  def initialize
    @selection = TestSelection.new
    @selection.target_all_time = false
  end

  def num_days_back=(num_days_back)
    @selection.num_days_back = num_days_back
  end

  def target_date=(target_date)
    @selection.target_date = target_date
  end

  def any_string(parts)
    if parts.empty?
      nil
    elsif parts.count == 1
      parts.first
    else
      "#{parts.join('|')}"
    end
  end
end

describe TestPipelineDatePattern do
  let(:target_date) { '@scheduledStartTime' }
  let(:sep) { '|' }
  subject { described_class.new }

  before { subject.target_date = target_date }

  context 'with 0 days back' do
    before { subject.num_days_back = 0 }

    describe '#date_pattern' do
      let(:pattern_matcher) do
        TestDatePatternMatcher.new(subject.date_pattern, target_date, sep)
      end

      it 'contains just target_date' do
        expect(pattern_matcher.day_offsets).to eq([0])
        expect(pattern_matcher.month_offsets).to eq([])
        expect(pattern_matcher.year_offsets).to eq([])
      end
    end
  end

  context 'with 59 days back' do
    before { subject.num_days_back = 59 }

    describe '#date_pattern' do
      let(:pattern_matcher) do
        TestDatePatternMatcher.new(subject.date_pattern, target_date, sep)
      end

      it 'contains 60 individual days' do
        expect(pattern_matcher.day_offsets.sort).to eq((0..59).to_a)
      end

      it 'contains no months' do
        expect(pattern_matcher.month_offsets).to eq([])
      end

      it 'contains no years' do
        expect(pattern_matcher.year_offsets).to eq([])
      end
    end
  end

  context 'with 60 days back' do
    before { subject.num_days_back = 60 }

    describe '#date_pattern' do
      let(:pattern_matcher) do
        TestDatePatternMatcher.new(subject.date_pattern, target_date, sep)
      end

      it 'contains 60 individual days' do
        expected_days = (0..29).to_a + (31..60).to_a
        expect(pattern_matcher.day_offsets.sort).to eq(expected_days)
      end

      it 'contains 1 month' do
        expect(pattern_matcher.month_offsets).to eq([30])
      end

      it 'contains no years' do
        expect(pattern_matcher.year_offsets).to eq([])
      end
    end
  end

  context 'with 729 days back' do
    before { subject.num_days_back = 729 }

    describe '#date_pattern' do
      let(:pattern_matcher) do
        TestDatePatternMatcher.new(subject.date_pattern, target_date, sep)
      end

      it 'contains 60 individual days' do
        expected_days = (0..29).to_a + (700..729).to_a
        expect(pattern_matcher.day_offsets.sort).to eq(expected_days)
      end

      it 'contains 24 individual months' do
        expected_months = ((30..674).step(28)).to_a
        expect(pattern_matcher.month_offsets.sort).to eq(expected_months)
      end

      it 'contains no years' do
        expect(pattern_matcher.year_offsets).to eq([])
      end
    end
  end

  context 'with 730 days back' do
    before { subject.num_days_back = 730 }

    describe '#date_pattern' do
      let(:pattern_matcher) do
        TestDatePatternMatcher.new(subject.date_pattern, target_date, sep)
      end

      it 'contains 60 individual days' do
        expected_days = (0..29).to_a + (701..730).to_a
        expect(pattern_matcher.day_offsets.sort).to eq(expected_days)
      end

      it 'contains 24 individual months' do
        expected_months = (30..394).step(28).to_a + (422..674).step(28).to_a
        expect(pattern_matcher.month_offsets.sort).to eq(expected_months)
      end

      it 'contains 1 year' do
        expect(pattern_matcher.year_offsets).to eq([365])
      end
    end
  end
end
