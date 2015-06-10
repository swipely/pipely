require 'json'
require 'pipely/fog_client'

describe Pipely::FogClient do
  let(:pipeline_id) { 'df-062006031I8JY09OVJHN' }

  subject { described_class.new(pipeline_id) }

  describe '#task_states_by_scheduled_start' do
    let(:instances_path) do
      File.expand_path('../../../fixtures/pipeline_activity_instances.json',
                       __FILE__)
    end

    let(:all_instances) { JSON.parse(File.read(instances_path)) }

    before do
      allow(subject).to receive(:all_instances).and_return(all_instances)
    end

    let(:result) { subject.task_states_by_scheduled_start }

    let(:scheduled_start) { '2014-12-17T19:47:03' }

    let(:activities) { result[scheduled_start] }

    it 'returns activities for the scheduled start' do
      expect(activities).to_not be(nil)
    end

    it 'returns expected number of activities' do
      expect(activities).to have(11).elements
    end

    describe 'compute recent tickets activity' do
      let(:compute_recent) { activities['ComputeRecentTickets'] }

      it 'has expected execution state' do
        expect(compute_recent[:execution_state]).to eq 'FINISHED'
      end

      it 'has expected run time' do
        expect(compute_recent[:run_time]).to eq '00:03:04'
      end
    end
  end
end
