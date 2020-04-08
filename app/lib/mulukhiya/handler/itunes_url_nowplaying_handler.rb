module Mulukhiya
  class ItunesURLNowplayingHandler < NowplayingHandler
    def initialize(params = {})
      super(params)
      @tracks = {}
      @service = ItunesService.new
    end

    def updatable?(keyword)
      return false unless uri = ItunesURI.parse(keyword)
      return false unless uri.track.present?
      @tracks[keyword] = uri.track
      return true
    rescue => e
      errors.push(class: e.class.to_s, message: e.message)
      return false
    end

    def update(keyword)
      return unless track = @tracks[keyword]
      push(track['trackName'])
      push(track['artistName'])
      tags.concat(ArtistParser.new(track['artistName']).parse)
    end
  end
end
