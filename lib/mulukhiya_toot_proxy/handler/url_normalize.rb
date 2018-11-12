require 'addressable/uri'

module MulukhiyaTootProxy
  class UrlNormalizeHandler < UrlHandler
    def rewrite(link)
      return @status.sub!(link, Addressable::URI.parse(link).normalize.to_s)
    end
  end
end