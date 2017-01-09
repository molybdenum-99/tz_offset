require 'time'

# Simple class representing timezone offset (in minutes). Knows almost nothing
# about timezone name, DST or other complications, but useful when ONLY offset is known.
#
# Usage:
#
# ```ruby
# o = Reality::TZOffset.parse('UTC+3')
# # => #<Reality::TZOffset(UTC+03:00)>
#
# o.now
# # => 2016-04-16 19:01:40 +0300
# o.local(2016, 4, 1, 20, 30)
# # => 2016-04-01 20:30:00 +0300
# o.convert(Time.now)
# # => 2016-04-16 19:02:22 +0300
# ```
#
class TZOffset
  # Number of minutes in offset.
  #
  # @return [Fixnum]
  attr_reader :seconds

  # Symbolic offset name if available (like "EEST").
  #
  # @note
  #   TZOffset never tries to "guess" the name, it is only known if an object was parsed/created
  #   from it.
  #
  # @return [String]
  attr_reader :name

  # Full symbolic timezone description, as per wikipedia (like "Eastern European Summer Time"
  # for "EEST").
  #
  # @return [String]
  attr_reader :description

  # "Region" part of {#description}, like "Eastern European" for "EEST".
  #
  # @return [String]
  attr_reader :region

  class << self
    # @private
    MINUSES = /[−—–]/

    # Parses TZOffset from string. Understands several options like:
    #
    # * `GMT` (not all TZ names, just well-known
    #   [abbreviations](https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations));
    # * `UTC+3` (or `GMT+3`);
    # * `+03:30`;
    # * ..and several combinations.
    #
    # @return [TZOffset]
    def parse(text)
      return ABBREV[text.upcase] if ABBREV.key?(text.upcase)

      sec = parse_text(text.gsub(MINUSES, '-'))
      sec && new(sec)
    end

    def zero
      @zero ||= new(0)
    end

    private

    def parse_text(text)
      case text
      when /^[A-Z]{3}$/
        Time.zone_offset(text)
      when /^(?:UTC|GMT)?([+-]\d{1,2}:?\d{2})$/
        parse_zone_offset($1)

      when /^(?<sign>[+-]?)(?<hours>\d{1,2})(:(?<minutes>\d{2})(:(?<seconds>\d{2}))?)?$/
        parse_with_seconds(Regexp.last_match)

      when /^(?:UTC|GMT)?([+-]\d{1,2})/
        $1.to_i * 3600
      end
    end

    def parse_zone_offset(offset)
      Time.zone_offset(offset.sub(/^([+-])(\d):/, '\10\2:'))
    end

    def parse_with_seconds(match)
      (match[:sign] == '-' ? -1 : +1) *
        (match[:hours].to_i * 3600 + match[:minutes].to_i * 60 + match[:seconds].to_i)
    end
  end

  # Constructs offset from number of minutes. In most cases, you don't
  # want to use it, but rather {TZOffset.parse}.
  #
  # @param minutes [Fixnum] Number of minutes in offset.
  def initialize(seconds, name: nil, description: nil, region: nil, isdst: nil)
    @seconds = seconds
    @name = name
    @description = description
    @isdst = isdst
    @region = region
  end

  def minutes
    seconds.abs / 60 * (seconds <=> 0)
  end

  alias_method :to_i, :seconds

  # @return [String]
  def inspect
    nm = name ? " (#{name})" : ''

    '#<%s %s%02i:%02i%s%s>' %
      [self.class.name, sign, *minutes.abs.divmod(60), inspectable_seconds, nm]
  end

  # @return [String]
  def to_s
    '%s%02i:%02i%s' % [sign, *minutes.abs.divmod(60), inspectable_seconds]
  end

  def +(other)
    TZOffset.new(seconds + other.seconds) # TODO: + num, type control, specs
  end

  # If offset is symbolic (e.g., "EET", not just "+02:00"), returns whether it is daylight
  # saving time offset.
  #
  # See also {#opposite} for obtaining non-DST related to current DST offset and vice versa.
  def dst?
    @isdst
  end

  def zero?
    @seconds.zero?
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
    t = tm.getutc + seconds

    # FIXME: usec are lost
    mk(t.year, t.month, t.day, t.hour, t.min, t.sec)
  end

  # Like Ruby's `Time.now`, but in current offset.
  #
  # @return [Time] Current time in that offset.
  def now
    convert(Time.now)
  end

  # For symbolic offsets, returns opposite (DST for non-DST and vice versa) offset object if
  # known, `nil` otherwise.
  #
  # @example
  #   eet = TZOffset.parse('EET')
  #   # => #<TZOffset +02:00 (EET)>
  #   eet.opposite
  #   # => #<TZOffset +03:00 (EEST)>
  #   TZOffset.parse('+8').opposite
  #   # => nil
  #
  # @return [TZOffset]
  def opposite
    return nil unless region
    ABBREV.values.flatten.detect { |tz| tz.region == region && tz.dst? == !dst? }
  end

  # Like `Time.parse`, but produces time in current offset.
  #
  # @note
  #   If time string contains timezone abbreviation or offset by itself, it is just ignored.
  #   The method is intended for "quick-n-dirty" parsing of things like "what is 12:30 in
  #   CEST currently?"
  #
  # @example
  #   # My current date and zone
  #   Time.parse('12:30')
  #   # => 2016-10-26 12:30:00 +0300
  #   TZOffset.parse('PDT').parse('12:30')
  #   # => 2016-10-26 12:30:00 -0700
  #   # Now I can know what it will be for me when somebody
  #   # says "I'll be available 12:30 PDT tomorrow":
  #   TZOffset.parse('PDT').parse('12:30').localtime
  #   # => 2016-10-26 22:30:00 +0300
  #
  # @param str [String] Same string that `Time.parse` could accept.
  # @return [Time] Time parsed from `str` into current offset.
  def parse(str)
    t = Time.parse(str)
    t && local(t.year, t.month, t.day, t.hour, t.min, t.sec)
  end

  private

  def inspectable_seconds
    (seconds.abs % 60).zero? ? '' : ':%02i' % (seconds.abs % 60)
  end

  def sign
    minutes < 0 ? '-' : '+'
  end

  def mk(*components)
    Time.new(*components, to_i)
  end
end

require_relative 'tz_offset/abbrev'
