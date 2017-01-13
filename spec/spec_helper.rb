require 'simplecov'
SimpleCov.start

require 'rspec/its'
require 'timecop'

require 'saharspec/its_call'

$:.unshift 'lib'
require 'tz_offset'
