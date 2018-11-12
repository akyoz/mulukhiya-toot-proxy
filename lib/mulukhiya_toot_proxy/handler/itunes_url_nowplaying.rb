module MulukhiyaTootProxy
  class ItunesUrlNowplayingHandler < NowplayingHandler
    def initialize
      super
      @tracks = {}
      @service = ItunesService.new
    end

    def updatable?(keyword)
      return false unless uri = ItunesUri.parse(keyword)
      return false unless uri.itunes?
      return false unless uri.track.present?
      @tracks[keyword] = uri.track
      return true
    rescue
      return false
    end

    def update(keyword, status)
      return unless track = @tracks[keyword]
      status.push(track['trackName'])
      if @config['local']['nowplaying']['hashtag']
        status.push(ItunesService.create_tags(track['artistName']).join(' '))
      else
        status.push(track['artistName'])
      end
      return unless uri = @service.amazon_uri(track)
      status.push(uri.to_s)
      return unless uri = @service.spotify_uri(track)
      status.push(uri.to_s)
    end
  end
end