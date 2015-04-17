require 'pipely/build/daily_scheduler'
require 'timecop'
describe Pipely::Build::DailyScheduler do

  let(:start_time) { "11:00:00" }
  subject { described_class.new(start_time) }

  describe "#period" do
    it "is '24 hours'" do
      expect(subject.period).to eq('24 hours')
    end
  end

  context "if the start time is garbage" do
    let(:start_time) { "0ksnsnk" }
    it 'Raises an error' do
      expect {described_class.new(start_time)}.to raise_exception ArgumentError
    end
  end

  describe "#start_date_time" do
    context "if the start time is 11:00:00 UTC" do
      let(:start_time) { "11:00:00" }
      it "and it is after that it chooses the start time tomorrow" do
        Timecop.freeze(Time.utc(2013, 6, 13, 16, 12, 30)) do
          expect(subject.start_date_time).to eq("2013-06-14T11:00:00")
        end
      end

      it "and it is before that it chooses the start time today" do
        Timecop.freeze(Time.utc(2013, 6, 13, 4, 12, 30)) do
          expect(subject.start_date_time).to eq("2013-06-13T11:00:00")
        end
      end
    end

    context "if the start time has is badly formatted" do
      let(:start_time) { "9:00:" }
      it "chooses the start time today" do
        Timecop.freeze(Time.utc(2013, 6, 13, 4, 12, 30)) do
          expect(subject.start_date_time).to eq("2013-06-13T09:00:00")
        end
      end
      it "chooses the start time tomorrow" do
        Timecop.freeze(Time.utc(2013, 6, 13, 11, 12, 30)) do
          expect(subject.start_date_time).to eq("2013-06-14T09:00:00")
        end
      end
    end
  end
end
