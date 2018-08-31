require 'addressable/uri'
require 'httparty'
require 'nokogiri'
require 'mulukhiya/handler/url_handler'

module MulukhiyaTootProxy
  class CanonicalHandler < UrlHandler
    def initialize
      super
      @canonicals = {}
    end

    def rewrite(link)
      @status.sub!(link, @canonicals[link]) if @canonicals[link].present?
    end

    private

    def rewritable?(link)
      uri = Addressable::URI.parse(link)
      body = Nokogiri::HTML.parse(HTTParty.get(uri.normalize).body, nil, 'utf-8')
      elements = body.xpath('//link[@rel="canonical"]')
      return false unless elements.present?
      uri = Addressable::URI.parse(elements.first.attribute('href'))
      @canonicals[link] = uri.to_s if uri.absolute?
      return @canonicals[link].present?
    end
  end
end