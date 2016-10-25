describe TZOffset do
  describe '.parse' do
    def from(str)
      described_class.parse(str)
    end

    def minutes_from(str)
      from(str).minutes
    end

    it 'can be created from offset str' do
      expect(minutes_from('-01:00')).to eq -60
      expect(minutes_from('+01:00')).to eq 60
      expect(minutes_from('−01:00')).to eq -60
      expect(minutes_from('−02:30')).to eq -150
      expect(minutes_from('+05:45')).to eq 60*5 + 45
      expect(minutes_from('UTC')).to eq 0
      expect(minutes_from('UTC+01:00')).to eq 60
      expect(minutes_from('UTC+2')).to eq 120
      expect(minutes_from('+0200')).to eq 120
      expect(minutes_from('UTC+5:45')).to eq 60*5 + 45
    end

    it 'preserves offset name for named offsets' do
      expect(from('CEST').name).to eq 'CEST'
      expect(from('+0200').name).to be_nil
    end

    it 'parses even offset names unknown to Ruby' do
      expect(minutes_from('CEST')).to eq 120
    end

    it 'returns several results for ambigous tz abbrs' do
      expect(from('CDT'))
        .to be_an(Array)
        .and have_attributes(size: 2)
        .and all(be_a(described_class))
    end

    it 'returns nil for unparseable' do
      expect(from('WTF')).to be_nil
    end
  end

  def off(*val)
    described_class.new(*val)
  end

  describe '#initialize' do
    it 'can be created from number of minutes' do
      expect(off(-60).minutes).to eq -60
      expect(off( 60).minutes).to eq 60
    end

    it 'can have optional name' do
      expect(off(-60, name: 'EET').name).to eq 'EET'
      expect(off(-60).name).to be_nil
    end
  end

  describe '#inspect' do
    def at(*val)
      off(*val).inspect
    end

    it 'works' do
      expect(at(-60)).to eq '#<TZOffset -01:00>'
      expect(at(+60)).to eq '#<TZOffset +01:00>'
      expect(at(-150)).to eq '#<TZOffset -02:30>'
      expect(at(5 * 60 + 45)).to eq '#<TZOffset +05:45>'
    end

    it 'preserves timezone name when available' do
      expect(at(120, name: 'CEST')).to eq '#<TZOffset +02:00 (CEST)>'
    end
  end

  describe '#to_s' do
    def at(val)
      off(val).to_s
    end

    it 'works' do
      expect(at(-60)).to eq '-01:00'
      expect(at(+60)).to eq '+01:00'
      expect(at(-150)).to eq '-02:30'
    end
  end

  describe '#==' do
    it 'looks at minutes' do
      expect(off(60)).to eq off(60)
      expect(off(60)).to eq off(60, name: 'EET')
      expect(off(60)).not_to eq off(120)
    end

    it 'does not fails on incompatible objects' do
      expect(off(60)).not_to eq 60
    end
  end

  context '<=>' do
    it 'looks at minutes' do
      expect(off(60) <=> off(60)).to eq 0
      expect(off(60) <=> off(60, name: 'EET')).to eq 0
      expect(off(60) <=> off(120)).to eq -1
      expect(off(60) <=> off(30)).to eq 1
    end

    it 'fails on incompatible objects' do
      expect { off(60) <=> 60 }.to raise_error(ArgumentError)
    end
  end

  describe '#local' do
    let(:offset) { TZOffset.parse('+5:45') }

    subject { offset.local(2016, 1, 29, 18, 15, 0) }

    it { is_expected.to eq Time.new(2016, 1, 29, 18, 15, 0, '+05:45') }
  end

  describe '#convert' do
    let(:tm) { Time.new(2016, 1, 29, 14, 30, 0, '+02:00') }
    let(:offset) { TZOffset.parse('UTC+5:45') }

    subject { offset.convert(tm) }

    it { is_expected.to eq Time.new(2016, 1, 29, 18, 15, 0, '+05:45') }
  end

  describe '#now' do
    let(:tm) { Time.new(2016, 1, 29, 14, 30, 0, '+02:00') }

    before{
      Timecop.freeze(tm)
    }

    let(:offset) { TZOffset.parse('+5:45') }
    subject { offset.now }
    it { is_expected.to eq Time.new(2016, 1, 29, 18, 15, 0, '+05:45') }
  end
end
