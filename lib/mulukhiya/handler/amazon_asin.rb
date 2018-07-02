require 'mulukhiya/amazon_uri'
require 'mulukhiya/handler/url_handler'

module MulukhiyaTootProxy
  class AmazonAsinHandler < UrlHandler
    def rewrite(link)
      uri = AmazonURI.parse(link)
      uri.associate_id = associate_id
      @status.sub!(link, uri.shorten.to_s)
    end

    private

    def rewritable?(link)
      return AmazonURI.parse(link).shortenable?
    end

    def associate_id
      return @config['local']['amazon']['associate_id']
    rescue
      return nil
    end
  end
end
