require 'httparty'
require 'mulukhiya/config'
require 'mulukhiya/package'
require 'mulukhiya/itunes_uri'
require 'mulukhiya/external_service_error'
require 'json'

module MulukhiyaTootProxy
  class ItunesService
    def initialize
      @config = Config.instance
    end

    def search(keyword, category)
      response = HTTParty.get(create_search_uri(keyword, category), {
        headers: {
          'User-Agent' => Package.user_agent,
        },
      })
      response = JSON.parse(response.strip)
      return nil unless response['results'].present?
      return response['results'].first
    rescue => e
      raise ExternalServiceError, e.message
    end

    def lookup(id)
      response = HTTParty.get(create_lookup_uri(id), {
        headers: {
          'User-Agent' => Package.user_agent,
        },
      })
      response = JSON.parse(response.strip)
      return nil unless response['results'].present?
      return response['results'].first
    rescue => e
      raise ExternalServiceError, e.message
    end

    private

    def create_search_uri(keyword, category)
      uri = ItunesURI.parse(@config['application']['itunes']['urls']['search'])
      uri.query_values = {
        term: keyword,
        media: category,
        country: @config['local']['itunes']['country'],
        lang: @config['local']['itunes']['lang'],
      }
      return uri
    end

    def create_lookup_uri(id)
      uri = ItunesURI.parse(@config['application']['itunes']['urls']['lookup'])
      uri.query_values = {
        id: id,
        country: @config['local']['itunes']['country'],
        lang: @config['local']['itunes']['lang'],
      }
      return uri
    end
  end
end
