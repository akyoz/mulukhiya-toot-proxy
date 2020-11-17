module Mulukhiya
  class YouTubeURI < Ginseng::YouTube::URI
    include Package

    def album_name
      return nil
    end

    alias track_name title

    def artists
      return ArtistParser.new(artist).parse
    end

    def artist
      if auto_generated_description?
        tags = data.dig('snippet', 'tags')
        tags.each do |tag|
          return tag unless tag.match?('^[ _a-zA-Z0-9]+$')
        end
        return tags.first if tags.first
      end
      return channel.sub(/ - Topic$/, '') if music?
      return channel
    end

    def auto_generated_description?
      return data.dig('snippet', 'description').end_with?('Auto-generated by YouTube.')
    end
  end
end
