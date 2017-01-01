require 'yaml'

class TZOffset
  # @private
  PATH = File.expand_path('../data/abbreviations.yaml', __FILE__)

  # @private
  #
  # List of Timezone abbreviations, loaded from datafile distributed with a gem
  # (abbreviations.yaml) and used when parsing timezones.
  #
  # Rendered really ugly by YARD... So, private.
  ABBREV =
    YAML
    .load_file(PATH)
    .map { |row|
      TZOffset.new(
        row.fetch(:val) * 60,
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
