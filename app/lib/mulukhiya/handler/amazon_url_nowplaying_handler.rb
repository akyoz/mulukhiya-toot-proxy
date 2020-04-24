module Mulukhiya
  class AmazonURLNowplayingHandler < NowplayingHandler
    def initialize(params = {})
      super
      @items = {}
      @service = AmazonService.new
    rescue => e
      errors.push(class: e.class.to_s, message: e.message)
    end

    def disable?
      return super || !AmazonService.config? || !@service
    end

    def updatable?(keyword)
      return false unless uri = AmazonURI.parse(keyword)
      return false unless uri.item.present?
      @items[keyword] = uri.item.merge('url' => uri.to_s)
      return true
    rescue => e
      errors.push(class: e.class.to_s, message: e.message, keyword: keyword)
      return false
    end

    def update(keyword)
      return unless item = @items[keyword]
      push(item.dig('ItemInfo', 'Title', 'DisplayValue'))
      return unless contributors = item.dig('ItemInfo', 'ByLineInfo', 'Contributors')
      push(contributors.map {|v| v['Name']}.join(', '))
      tags.concat(ArtistParser.new(contributors.map {|v| v['Name']}.join('、')).parse)
      result.push(url: item['url'])
    end
  end
end
