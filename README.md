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

# Also work with most common timezone abbreviations
TZOffset.parse('CEST').local(2016, 10, 20, 18).localtime

```

In other words, `TZOffset` is simple, no-magic, incapsulated abstraction of "time offset".

## Features and problems

* Easy-to-use, intuitive, and dead simple;
* No brains included
* Knows about all common timezone abbreviations (got them from
  [there](https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations));
* Preserves timezone name into produced `Time` object when it is possible:

## Installation

Do your usual routine with gem named `tz_offset` (e.g. `gem install tz_offset` or add
`gem "tz_offset` to your `Gemfile`).

## Usage
