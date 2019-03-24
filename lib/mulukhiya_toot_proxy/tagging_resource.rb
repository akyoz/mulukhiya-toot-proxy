require 'addressable/uri'

module MulukhiyaTootProxy
  class TaggingResource
    def parse
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def fetch
      response = @http.get(uri).parsed_response
      raise 'empty' unless response.present?
      return response
    rescue => e
      raise Ginseng::GatewayError, "'#{url}' is invalid (#{e.message})"
    end

    def uri
      @uri ||= Addressable::URI.parse(@params['/url'])
      return @uri
    end

    def self.all
      return enum_for(__method__) unless block_given?
      Config.instance['/tagging/dictionaries'].each do |dic|
        yield TaggingResource.create(dic)
      end
    end

    def self.create(params)
      params['type'] ||= 'multi_field'
      require "mulukhiya_toot_proxy/tagging_resource/#{params['type']}"
      return "MulukhiyaTootProxy::#{params['type'].camelize}TaggingResource".constantize.new(params)
    end

    private

    def create_pattern(word)
      return Regexp.new(word.gsub(/[^[:alnum:]]/, '.?'))
    end

    def initialize(params)
      @params = Config.flatten('', params)
      @logger = Logger.new
      @http = HTTP.new
    end
  end
end