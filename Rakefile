$:.unshift 'lib'
require 'tz_offset'

namespace :dev do
  desc 'Parses https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations to create data'
  task :fetch_abbr do
    require 'infoboxer'
    Infoboxer.wp.get('List of time zone abbreviations').tables.first
      .rows[1..-1].map { |r| r.cells.map(&:text_) }
  end
end
