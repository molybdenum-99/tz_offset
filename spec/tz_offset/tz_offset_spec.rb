describe TZOffset do
  describe '.parse' do
    def from(str)
      described_class.parse(str)
    end

    def minutes_from(str)
      from(str).minutes
    end

    def seconds_from(str)
      from(str).seconds
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
      expect(minutes_from('±00:00UTC')).to eq 0

      expect(seconds_from('5:53:03')).to eq 5*3600 + 53*60 + 3
      expect(seconds_from('-0:01:15')).to eq -(1*60 + 15)
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

  describe '.zero' do
    specify { expect(described_class.zero).to eq TZOffset.new(0) }
  end

  def off(*val)
    described_class.new(*val)
  end

  describe '#initialize' do
    it 'can be created from number of seconds' do
      expect(off(-3600).seconds).to eq -3600
      expect(off( 3600).seconds).to eq 3600
    end

    it 'can have optional name' do
      expect(off(-3600, name: 'EET').name).to eq 'EET'
      expect(off(-3600).name).to be_nil
    end
  end

  describe '#inspect' do
    def at(*val)
      off(*val).inspect
    end

    it 'works' do
      expect(at(-3600)).to eq '#<TZOffset -01:00>'
      expect(at(+3600)).to eq '#<TZOffset +01:00>'
      expect(at(-9000)).to eq '#<TZOffset -02:30>'
      expect(at(5 * 3600 + 45 * 60)).to eq '#<TZOffset +05:45>'
      expect(at(-(1*60 + 15))).to eq '#<TZOffset -00:01:15>'
    end

    it 'preserves timezone name when available' do
      expect(at(2 * 3600, name: 'CEST')).to eq '#<TZOffset +02:00 (CEST)>'
    end

    it 'shows non-zero seconds' do
      expect(at(3600 + 1800 + 5)).to eq '#<TZOffset +01:30:05>'
    end
  end

  describe '#to_s' do
    def at(val)
      off(val).to_s
    end

    it 'works' do
      expect(at(-60*60)).to eq '-01:00'
      expect(at(+60*60)).to eq '+01:00'
      expect(at(-150*60)).to eq '-02:30'
      expect(at(-75)).to eq '-00:01:15'
    end
  end

  describe '#-@' do
    subject { -TZOffset.parse('+01:00') }

    it { is_expected.to eq TZOffset.parse('-01:00') }
  end

  describe '#+' do
    subject { TZOffset.parse('+01:00') + other }

    context 'with other offset' do
      let(:other) { TZOffset.parse('-03:15') }
      it { is_expected.to eq TZOffset.parse('-02:15') }
    end

    context 'with numeric' do
      let(:other) { 120 }
      it { is_expected.to eq TZOffset.parse('+01:02') }
    end

    context 'with anything else' do
      let(:other) { 'xxx' }
      its_block { is_expected.to raise_error ArgumentError }
    end
  end

  describe '#-' do
    subject { TZOffset.parse('+01:00').method(:-) }

    its_call(TZOffset.parse('-03:15')) { is_expected.to ret TZOffset.parse('+04:15') }
    its_call(120) { is_expected.to ret TZOffset.parse('+00:58') }
    its_call('xxx') { is_expected.to raise_error ArgumentError }
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

    it 'returns nothing on incompatible objects' do
      expect(off(60) <=> 60).to be_nil
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
    its(:utc_offset) { is_expected.to eq 5*3600 + 45*60 }

    context 'with seconds' do
      let(:offset) { TZOffset.parse('+5:45:20') }

      it { is_expected.to eq Time.new(2016, 1, 29, 18, 15, 20, '+05:45:20') }
      its(:utc_offset) { is_expected.to eq 5*3600 + 45*60 + 20 }
    end
  end

  describe '#now' do
    let(:tm) { Time.new(2016, 1, 29, 14, 30, 0, '+02:00') }

    before{
      Timecop.freeze(tm)
    }

    let(:offset) { TZOffset.parse('+5:45') }
    subject { offset.now }

    it { is_expected.to eq Time.new(2016, 1, 29, 18, 15, 0, '+05:45') }
    its(:utc_offset) { is_expected.to eq 5*3600 + 45*60 }
  end

  describe '#parse' do
    let(:tm) { Time.new(2016, 1, 29, 14, 30, 0, '+02:00') }
    let(:offset) { TZOffset.parse('+5:45') }

    before{
      Timecop.freeze(tm)
    }

    subject { offset.parse('18:15') }

    it { is_expected.to eq Time.new(2016, 1, 29, 18, 15, 0, '+05:45') }
    its(:utc_offset) { is_expected.to eq 5*3600 + 45*60 }
  end

  describe '#zero?' do
    context 'when zero' do
      subject { TZOffset.new(0) }
      it { is_expected.to be_zero }
    end

    context 'when non-zero' do
      subject { TZOffset.new(1) }
      it { is_expected.not_to be_zero }
    end
  end

  describe '#opposite' do
    specify { expect(TZOffset.parse('EET').opposite).to eq TZOffset.parse('EEST') }
    specify { expect(TZOffset.parse('EEST').opposite).to eq TZOffset.parse('EET') }
  end
end
