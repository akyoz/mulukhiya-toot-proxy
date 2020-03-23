module Mulukhiya
  class AmazonURLHandler < URLHandler
    def rewrite(uri)
      source = AmazonURI.parse(uri.to_s)
      dest = source.clone
      dest.associate_tag = nil
      dest.associate_tag = AmazonService.associate_tag if affiliate?
      dest = dest.shorten
      @status.sub!(source.to_s, dest.to_s)
      return dest
    end

    private

    def affiliate?
      return false if sns.account.config['/amazon/affiliate'].is_a?(FalseClass)
      return false unless @config['/amazon/affiliate']
      return true
    rescue => e
      @logger.error(e)
      return true
    end

    def rewritable?(uri)
      uri = AmazonURI.parse(uri.to_s) unless uri.is_a?(AmazonURI)
      return uri.shortenable?
    rescue => e
      @logger.error(e)
      return false
    end
  end
end