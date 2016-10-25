# TZOffset

Ever tried to convert your distant friend's or colleague's phrase "OK, let's connect tomorrow
at 6 pm my time (GMT+8)" into easily calculatable Ruby code? E.g. what time it would be in your
timezone at 18:00 GMT+8? What is your favorite solution? Now it should be that:

```ruby
TZOffset.parse('GMT+8').local(2016, 10, 20, 18).localtime
# => 2016-10-20 13:00:00 +0300

# or just
TZOffset.parse('+8').local(2016, 10, 20, 18).localtime
# => 2016-10-20 13:00:00 +0300

# Also works with most common timezone abbreviations
TZOffset.parse('CEST').local(2016, 10, 20, 18).localtime
# => 2016-10-20 19:00:00 +0300
```

In other words, `TZOffset` is simple, no-magic, incapsulated abstraction of "time offset".

## Features and problems

* Easy-to-use, intuitive, dead simple, OS independent;
* No brains included: no huge and comprehensive database of historical times, no automatic
  DST conversion; you just know offset you need, and have it as a near-to-mathematical
  value;
* Simple value objects, easily converted to/from YAML (so you can save them to databases,
  pass to delayed jobs and so on);
* Knows about all common timezone abbreviations (got them from
  [Wikipedia list](https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations));
* For ambiguous abbreviations, just returns list of all of them:

```ruby
TZOffset.parse('EET')
# => #<TZOffset +02:00 (EET)>
TZOffset.parse('CDT')
# => [#<TZOffset -05:00 (CDT)>, #<TZOffset -04:00 (CDT)>]
```

* For symbolic timezones, provides a description, if available:

```ruby
TZOffset.parse('CDT').map(&:description)
# => ["Central Daylight Time (North America)", "Cuba Daylight Time"]
TZOffset.parse('CDT').map(&:region)
# => ["Central", "Cuba"]

# NB: Just "Central", "Eastern" and so on is related to North America in timezones nomenclature
```

* for [DST](https://en.wikipedia.org/wiki/Daylight_saving_time) and non-DST timezones provides
  dst-flag and counterpart timezone, if available:

```ruby
eet = TZOffset.parse('EET')
# => #<TZOffset +02:00 (EET)>
eet.dst?
# => false
eet.opposite
# => #<TZOffset +03:00 (EEST)>
[eet.description, eet.opposite.description]
# => ["Eastern European Time", "Eastern European Summer Time"]
```

## Installation

Do your usual routine with gem named `tz_offset` (e.g. `gem install tz_offset` or add
`gem "tz_offset` to your `Gemfile`).

## Usage

Most of it is already shown above!

```ruby
require 'tz_offset'

off = TZOffset.parse('-02:30')
# => #<TZOffset -02:30>
off.now
# => 2016-10-25 16:07:55 -0230
off.local(2016, 10, 1)
# => 2016-10-01 00:00:00 -0230

eet = TZOffset.parse('EET')
# => #<TZOffset +02:00 (EET)>
eet.now
# => 2016-10-25 20:29:03 +0200
eet.description
# => "Eastern European Time"
eet.region
# => "Eastern European"
eet.opposite
# => #<TZOffset +03:00 (EEST)>
eet.opposite.now
# => 2016-10-25 21:39:26 +0300
```

## Author

[Victor Shepelev](http://zverok.github.io/) -- extracted from [reality](https://github.com/molybdenum-99/reality)
project.

## License

MIT.
