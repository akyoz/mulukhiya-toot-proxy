module Mulukhiya
  class ItunesNowplayingHandler < NowplayingHandler
    def initialize(params = {})
      super(params)
      @tracks = {}
      @service = ItunesService.new
    end

    def updatable?(keyword)
      return true if @tracks[keyword] = @service.search(keyword, 'music')
      return false
    rescue => e
      @logger.error(e)
      return false
    end

    def update(keyword)
      return unless track = @tracks[keyword]
      return unless uri = ItunesURI.parse(track['trackViewUrl'])
      push(uri.shorten.to_s)
    end
  end
end
