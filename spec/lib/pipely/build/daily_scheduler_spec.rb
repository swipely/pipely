require 'pipely/build/daily_scheduler'

describe Pipely::Build::DailyScheduler do

  let(:start_time) { "11:00:00" }

  subject { described_class.new(start_time) }

  describe "#period" do
    it "is '24 hours'" do
      expect(subject.period).to eq('24 hours')
    end
  end

  describe "#start_date_time" do
    context "if the start time has already happened today in UTC" do
      it "chooses the start time tomorrow" do
        Timecop.freeze(Time.utc(2013, 6, 12, 16, 12, 30)) do
          expect(subject.start_date_time).to eq("2013-06-13T11:00:00")
        end
      end
    end

    context "if the start time has not happened yet today in UTC" do
      it "chooses the start time today" do
        Timecop.freeze(Time.utc(2013, 6, 13, 4, 12, 30)) do
          expect(subject.start_date_time).to eq("2013-06-13T11:00:00")
        end
      end
    end
  end

end
