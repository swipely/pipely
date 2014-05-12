require 'pipely/build/right_now_scheduler'

describe Pipely::Build::RightNowScheduler do

  describe "#period" do
    it "is '1 year'" do
      expect(subject.period).to eq('1 year')
    end
  end

  describe "#start_date_time" do
    it "chooses the current time as the start time" do
      Timecop.freeze(Time.utc(2013, 6, 12, 16, 12, 30)) do
        expect(subject.start_date_time).to eq("2013-06-12T16:12:30")
      end
    end
  end

end
