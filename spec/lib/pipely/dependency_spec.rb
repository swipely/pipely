require 'pipely/dependency'

describe Pipely::Dependency do

  describe '#color' do
    it 'defaults to "black"' do
      expect(subject.color).to eq('black')
    end
  end

end
