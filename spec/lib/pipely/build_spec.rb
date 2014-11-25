require 'pipely/build'

describe Pipely::Build do

  describe '.build_definition(template, environment, config_path)' do

    let(:template) { double }
    let(:environment) { 'production' }
    let(:config_path) { 'path/to/config' }

    let(:config) { double }

    before do
      allow(Pipely::Build::EnvironmentConfig).to receive(:load).
        with(config_path, environment.to_sym).
        and_return(config)
    end

    it 'builds a Definition' do
      expect(
        described_class.build_definition(template, environment, config_path)
      ).to eq(
        Pipely::Build::Definition.new(
          template,
          environment.to_sym,
          config
        )
      )
    end
  end

end
