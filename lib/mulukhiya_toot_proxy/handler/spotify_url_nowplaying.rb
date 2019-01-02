module MulukhiyaTootProxy
  class SpotifyURLNowplayingHandler < NowplayingHandler
    def initialize
      super
      @tracks = {}
      @service = SpotifyService.new
    end

    def updatable?(keyword)
      return false unless uri = SpotifyURI.parse(keyword)
      return false unless uri.track.present?
      @tracks[keyword] = uri.track
      return true
    rescue
      return false
    end

    def update(keyword, status)
      return unless track = @tracks[keyword]
      status.push(track.name)
      status.push(ArtistParser.new(track.artists.map(&:name).join('/')).parse.join(' '))
      [:amazon_uri, :itunes_uri].each do |method|
        next unless uri = @service.send(method, track)
        status.push(uri.to_s)
      end
    end
  end
end
