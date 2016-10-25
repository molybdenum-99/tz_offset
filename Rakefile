$:.unshift 'lib'
require 'tz_offset'
require 'tz_offset/tasks/extract_offsets'

namespace :dev do
  desc 'Parses https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations to create data'
  task :extract_offsets do
    TZOffset::Tasks::ExtractOffsets.new.run
  end
end
