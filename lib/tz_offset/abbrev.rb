require 'yaml'

class TZOffset
  PATH = File.expand_path('../data/abbreviations.yaml', __FILE__)

  ABBREV =
    YAML
    .load_file(PATH)
    .map { |row|
      TZOffset.new(
        row.fetch(:val),
        name: row.fetch(:abbr),
        description: row.fetch(:title),
        region: row.fetch(:region),
        isdst: row.fetch(:dst)
      )
    }
    .group_by(&:name)
    .map { |name, group| [name, group.count == 1 ? group.first : group] }
    .to_h
end
