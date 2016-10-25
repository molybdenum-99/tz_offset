require 'time'

class TZOffset
  # Number of minutes in offset.
  #
  # @return [Fixnum]
  attr_reader :minutes

  attr_reader :name

  attr_reader :description

  attr_reader :region

  # @private
  MINUSES = /[−—–]/

  # Parses TZOffset from string. Understands several options like:
  #
  # * `GMT` (not all TZ names, only those Ruby itself knows about);
  # * `UTC+3` (or `GMT+3`);
  # * `+03:30`;
  # * ..and several combinations.
  #
  # @return [TZOffset]
  def self.parse(text)
    return ABBREV[text.upcase] if ABBREV.key?(text.upcase)

    text = text.gsub(MINUSES, '-')

    sec =
      case text
      when /^[A-Z]{3}$/
        Time.zone_offset(text)
      when /^(?:UTC|GMT)?([+-]\d{1,2}:?\d{2})$/
        offset = $1
        Time.zone_offset(offset.sub(/^([+-])(\d):/, '\10\2:'))
      when /^(?:UTC|GMT)?([+-]\d{1,2})/
        $1.to_i * 3600
      end

    sec && new(sec / 60)
  end

  # Constructs offset from number of minutes. In most cases, you don't
  # want to use it, but rather {TZOffset.parse}.
  #
  # @param minutes [Fixnum] Number of minutes in offset.
  def initialize(minutes, name: nil, description: nil, region: nil, isdst: nil)
    @minutes = minutes
    @name = name
    @description = description
    @isdst = isdst
    @region = region
  end

  # @return [String]
  def inspect
    if name
      '#<%s %s%02i:%02i (%s)>' % [self.class.name, sign, *minutes.abs.divmod(60), name]
    else
      '#<%s %s%02i:%02i>' % [self.class.name, sign, *minutes.abs.divmod(60)]
    end
  end

  # @return [String]
  def to_s
    '%s%02i:%02i' % [sign, *minutes.abs.divmod(60)]
  end

  def dst?
    @isdst
  end

  # @return [Boolean]
  def <=>(other)
    other.is_a?(TZOffset) or raise ArgumentError, "Can't compare TZOffset with #{other.class}"
    minutes <=> other.minutes
  end

  include Comparable

  # @return [Boolean]
  def ==(other)
    other.class == self.class && other.minutes == minutes
  end

  # Like Ruby's `Time.local`, but in current offset.
  #
  # @return [Time] Constructed time in that offset.
  def local(*values)
    values << 0 until values.count == 6
    mk(*values)
  end

  # Converts `tm` into current offset.
  #
  # @param tm [Time] Time object to convert (with any offset);
  # @return [Time] Converted object.
  def convert(tm)
    t = tm.getutc + minutes * 60

    # FIXME: usec are lost
    mk(t.year, t.month, t.day, t.hour, t.min, t.sec)
  end

  # Like Ruby's `Time.now`, but in current offset.
  #
  # @return [Time] Current time in that offset.
  def now
    convert(Time.now)
  end

  def opposite
    return nil unless region
    ABBREV.values.flatten.detect { |tz| tz.region == region && tz.dst? == !dst? }
  end

  private

  def sign
    minutes < 0 ? '-' : '+'
  end

  def mk(*components)
    Time.new(*components, to_s)
  end
end

require_relative 'tz_offset/abbrev'
