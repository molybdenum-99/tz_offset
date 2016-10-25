require 'yaml'

class TZOffset
  ABBREV = YAML.load_file(File.expand_path('../data/abbreviations.yaml', __FILE__))
    .map { |row| TZOffset.new(row[:val], name: row[:abbr]) }
    .group_by(&:name)
    .map { |name, group| [name, group.count == 1 ? group.first : group] }
    .to_h
end
