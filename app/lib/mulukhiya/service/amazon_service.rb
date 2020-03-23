require 'vacuum'

module Mulukhiya
  class AmazonService
    def initialize
      @config = Config.instance
      @http = HTTP.new
      @logger = Logger.new
      return unless AmazonService.config?
      @vacuum = Vacuum.new(
        marketplace: @config['/amazon/marketplace'],
        access_key: @config['/amazon/access_key'],
        secret_key: @config['/amazon/secret_key'],
        partner_tag: AmazonService.associate_tag,
      )
    end

    def create_image_uri(asin)
      item = lookup(asin)
      ['Large', 'Medium', 'Small'].each do |size|
        uri = Ginseng::URI.parse(item.dig('Images', 'Primary', size, 'URL'))
        return uri if uri
      end
    end

    def search(keyword, categories)
      return nil unless AmazonService.config?
      cnt ||= 0
      categories.each do |category|
        response = @vacuum.search_items(keywords: keyword, search_index: category)
        raise response.status.to_s unless response.status == 200
        return JSON.parse(response.to_s)['SearchResult']['Items'].first['ASIN']
      end
      return nil
    rescue => e
      @logger.info(e)
      cnt += 1
      raise Ginseng::GatewayError, e.message, e.backtrace unless cnt <= retry_limit
      sleep(1)
      retry
    end

    def lookup(asin)
      cnt ||= 0
      response = @vacuum.get_items(item_ids: [asin], resources: @config['/amazon/resources'])
      raise response.status.to_s unless response.status == 200
      return JSON.parse(response.to_s)['ItemsResult']['Items'].first
    rescue => e
      @logger.info(e)
      cnt += 1
      raise Ginseng::GatewayError, e.message, e.backtrace unless cnt <= retry_limit
      sleep(1)
      retry
    end

    def create_item_uri(asin)
      uri = AmazonURI.parse(@config["/amazon/urls/#{@config['/amazon/marketplace']}"])
      uri.asin = asin
      return uri
    end

    def self.associate_tag
      return Config.instance['/amazon/associate_tag']
    rescue Ginseng::ConfigError
      return nil
    end

    def self.config?
      config = Config.instance
      config['/amazon/marketplace']
      config['/amazon/access_key']
      config['/amazon/secret_key']
      config['/amazon/associate_tag']
      return true
    rescue Ginseng::ConfigError
      return false
    end

    private

    def retry_limit
      return @config['/amazon/retry_limit']
    end
  end
end