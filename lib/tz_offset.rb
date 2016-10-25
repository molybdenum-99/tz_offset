require 'time'

class TZOffset
  # Number of minutes in offset.
  #
  # @return [Fixnum]
  attr_reader :minutes

  attr_reader :name

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

    sec = case text
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
  def initialize(minutes, name: nil)
    @minutes = minutes
    @name = name
  end

  # @return [String]
  def inspect
    if name
      '#<%s %+03i:%02i (%s)>' % [self.class.name, *minutes.divmod(60), name]
    else
      '#<%s %+03i:%02i>' % [self.class.name, *minutes.divmod(60)]
    end
  end

  # @return [String]
  def to_s
    '%+03i:%02i' % minutes.divmod(60)
  end

  # @return [Boolean]
  def <=>(other)
    other.is_a?(TZOffset) or fail ArgumentError, "Can't compare TZOffset with #{other.class}"
    minutes <=> other.minutes
  end

  include Comparable

  # @return [Boolean]
  def ==(other)
    other.class == self.class && other.minutes == self.minutes
  end

  # Like Ruby's `Time.local`, but in current offset.
  #
  # @return [Time] Constructed time in that offset.
  def local(*values)
    values << 0 until values.count == 6
    Time.new(*values, to_s)
  end

  # Converts `tm` into current offset.
  #
  # @param tm [Time] Time object to convert (with any offset);
  # @return [Time] Converted object.
  def convert(tm)
    pattern = tm.getutc + minutes * 60

    # FIXME: usec are lost
    Time.new(
      pattern.year,
      pattern.month,
      pattern.day,
      pattern.hour,
      pattern.min,
      pattern.sec,
      to_s
    )
  end

  # Like Ruby's `Time.now`, but in current offset.
  #
  # @return [Time] Current time in that offset.
  def now
    convert(Time.now)
  end

end

require_relative 'tz_offset/abbrev'
