describe TZOffset do
  describe '.parse'
  end

  describe '#initialize' do
    it 'can be created from number of minutes' do
      expect(described_class.new(-60).minutes).to eq -60
      expect(described_class.new( 60).minutes).to eq 60
    end
  end

  describe '#inspect' do
  end

  describe '#to_s' do
  end

  describe '#==' do
  end

  context 'Comparable' do
  end

  describe '#local' do
  end

  describe '#convert' do
  end

  describe '#now' do
  end
end
