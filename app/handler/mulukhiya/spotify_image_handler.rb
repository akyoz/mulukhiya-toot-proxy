module Mulukhiya
  class SpotifyImageHandler < ImageHandler
    def disable?
      return super || !SpotifyService.config?
    end

    def updatable?(uri)
      uri = SpotifyURI.parse(uri.to_s) unless uri.is_a?(SpotifyURI)
      return false unless uri.spotify?
      return false unless uri.track_id.present?
      return false unless uri.image_uri.present?
      return true
    rescue => e
      Slack.broadcast(e)
      @logger.error(e)
      return false
    end

    def create_image_uri(uri)
      uri = SpotifyURI.parse(uri.to_s) unless uri.is_a?(SpotifyURI)
      return SpotifyURI.parse(uri).image_uri
    end
  end
end
