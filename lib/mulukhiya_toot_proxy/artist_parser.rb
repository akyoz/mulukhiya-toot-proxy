module MulukhiyaTootProxy
  class ArtistParser
    def initialize(source)
      @source = source
      @config = Config.instance
      @logger = Logger.new
    end

    def parse
      tags = []
      patterns do |pattern_entry|
        next unless matches = @source.match(pattern_entry[:pattern])
        if pattern_entry[:delimited]
          split_artist(@source, true).each do |artist|
            tags.concat(ArtistParser.new(artist).parse)
          end
        else
          tags.concat(parse_part(matches, pattern_entry[:items]))
        end
        return tags
      end
      tags.push(@source)
      return tags
    rescue => e
      @logger.error(e)
    end

    private

    def parse_part(source, items)
      i = 0
      tags = []
      items.each do |item|
        i += 1
        next if item['drop']
        split_artist(source[i], item['split']).map{|v| tags.push(v)}
      end
      return tags
    end

    def patterns
      return enum_for(__method__) unless block_given?
      @config['/nowplaying/artist_parser/patterns'].each do |entry|
        output = {
          pattern: Regexp.new(entry['pattern']),
          delimited: entry['delimited'],
        }
        output[:items] = entry['items'] || []
        yield output
      end
    end

    def split_artist(artist, flag)
      pattern = Regexp.new("[#{Config.instance['/nowplaying/artist_parser/delimiters'].join}]")
      return flag ? artist.split(pattern) : [artist]
    end
  end
end
