require 'pipely/build/environment_config'

describe Pipely::Build::EnvironmentConfig do

  describe '.load(filename, environment)' do
    let(:filename) { 'path/to/config/yaml.yml' }

    let(:config) do
      YAML.load(<<-EOS)
        my_env:
          key: 'my_val'
        production:
          key: 'prod_val'
        staging:
          key: 'staging_val'
      EOS
    end

    before do
      allow(YAML).to receive(:load_file).with(filename) { config }
    end

    context 'given a custom environment' do
      subject { described_class.load(filename, 'my_env') }

      it 'loads config from a YAML file' do
        expect(subject[:key]).to eq('my_val')
      end
    end

    context 'given the "production" environment' do
      subject { described_class.load(filename, 'production') }

      it 'loads config from a YAML file' do
        expect(subject[:key]).to eq('prod_val')
      end

      it 'supports legacy defaults' do
        expect(subject[:s3_prefix]).to eq('production/:namespace')
        expect(subject[:scheduler]).to eq('daily')
      end
    end

    context 'given the "staging" environment' do
      subject { described_class.load(filename, 'staging') }

      it 'loads config from a YAML file' do
        expect(subject[:key]).to eq('staging_val')
      end

      it 'supports legacy defaults' do
        expect(subject[:s3_prefix]).to eq('staging/:whoami/:namespace')
        expect(subject[:scheduler]).to eq('now')
      end
    end
  end

end
