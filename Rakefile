require 'bundler/setup'
require 'rubygems/tasks'

$:.unshift 'lib'
require 'tz_offset'
require 'tz_offset/tasks/extract_offsets'

Gem::Tasks.new

namespace :dev do
  desc 'Parse https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations to update lib/data'
  task :extract_offsets do
    TZOffset::Tasks::ExtractOffsets.new.run
  end
end
