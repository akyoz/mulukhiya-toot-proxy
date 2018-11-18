module MulukhiyaTootProxy
  class AmazonAsinHandler < URLHandler
    def rewrite(link)
      uri = AmazonURI.parse(link)
      uri.associate_tag = AmazonService.associate_tag
      @status.sub!(link, uri.shorten.to_s)
    end

    private

    def rewritable?(link)
      return AmazonURI.parse(link).shortenable?
    end
  end
end
