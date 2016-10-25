class TZOffset
  # @private
  module Tasks
    class ExtractOffsets

      TZ = Struct.new(:abbr, :title, :region, :dst, :val)

      NO_TIME_SUFFIX = [
        'Gambier Islands',
        'South Georgia and the South Sandwich Islands',
        "Heure Avancée d'Europe Centrale francised name for CEST",
        'Marshall Islands',
        'Indian/Kerguelen'
      ]

      def run
        require 'infoboxer'

        data = Infoboxer.wp.get('List of time zone abbreviations').tables.first.rows[1..-1]
          .map { |r| r.cells.map(&:text_) }
          .reject { |cells| cells[0] == 'UTC' }
          .reject { |cells| cells[1].include?(' (Australia)') } # they are duplicated, like Australian Central Daylight Savings Time vs Central Summer Time (Australia)
          .reject { |cells| cells[2].include?(' - ') } # ASEAN time is range, not exact value
          .map { |abbr, title, val|
            [
              abbr,
              title
                .sub(/ Same zone as \S+$/, '')
                .sub(/^(#{NO_TIME_SUFFIX.join('|')})$/, '\1 Time'),
              val.sub('±00', '')
            ]
          }
          .map { |abbr, title, val| TZ.new(abbr, title, *parse_title(title), TZOffset.parse(val).minutes) }

        require 'yaml'
        require 'fileutils'

        FileUtils.mkdir_p 'lib/tz_offset/data'

        File.write 'lib/tz_offset/data/abbreviations.yaml', data.sort_by(&:abbr).map(&:to_h).to_yaml
      end

      private

      def parse_title(title)
        title =~ /^(.+?)((?: )(?:Standard|Summer|Daylight|Daylight Savings))? Time(?: \(.+\))?$/i or
          fail(ArgumentError, "Unparseable time title: #{title}")

        region, spec = $1, $2
        [region, /Summer|Daylight/ === spec]
      end
    end
  end
end
