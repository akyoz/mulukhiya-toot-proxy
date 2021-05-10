module Mulukhiya
  class FeedController < Controller
    get '/tag/:tag' do
      raise Ginseng::NotFoundError, 'Not Found' unless controller_class.feed?
      @renderer = TagFeedRenderer.new
      @renderer.tag = params[:tag]
      @renderer.status = 404 unless @renderer.exist?
      return @renderer.to_s
    rescue => e
      @renderer.status = e.status
      @renderer.message = {error: e.message}
      return @renderer.to_s
    end

    get '/media' do
      raise Ginseng::NotFoundError, 'Not Found' unless controller_class.media_catalog?
      raise Ginseng::NotFoundError, 'Not Found' unless controller_class.feed?
      @renderer = MediaFeedRenderer.new
      return @renderer.to_s
    rescue => e
      @renderer.status = e.status
      @renderer.message = {error: e.message}
      return @renderer.to_s
    end

    config['/feed/custom'].each do |entry|
      get File.join('/', entry['path']) do
        storage = RenderStorage.new
        raise Ginseng::NotFoundError, "Resource #{request.path} not found." unless command
        raise Ginseng::NotFoundError, "Resource #{request.path} not found." unless storage[command]
        return storage[command]
      rescue => e
        e = Ginseng::Error.create(e)
        @renderer = Ginseng::Web::XMLRenderer.new
        @renderer.status = e.status
        @renderer.message = {error: e.message}
        return @renderer.to_s
      end
    end
  end
end
