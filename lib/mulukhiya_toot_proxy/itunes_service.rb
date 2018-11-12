require 'httparty'
require 'json'

module MulukhiyaTootProxy
  class ItunesService
    def initialize
      Config.validate('/local/itunes/country')
      Config.validate('/local/itunes/lang')
      @config = Config.instance
    end

    def search(keyword, category)
      response = HTTParty.get(create_search_uri(keyword, category), {
        headers: {
          'User-Agent' => Package.user_agent,
        },
        ssl_ca_file: ENV['SSL_CERT_FILE'],
      })
      response = JSON.parse(response.strip)
      raise RequestError, response['errorMessage'] if response['errorMessage']
      return nil unless response['results'].present?
      return response['results'].first
    rescue RequestError => e
      raise RequestError, "#{category} ’#{keyword}' が見つかりません。 (#{e.message})"
    rescue => e
      raise ExternalServiceError, e.message
    end

    def lookup(id)
      response = HTTParty.get(create_lookup_uri(id), {
        headers: {
          'User-Agent' => Package.user_agent,
        },
        ssl_ca_file: ENV['SSL_CERT_FILE'],
      })
      response = JSON.parse(response.strip)
      raise RequestError, response['errorMessage'] if response['errorMessage']
      return nil unless response['results'].present?
      return response['results'].first
    rescue RequestError => e
      raise RequestError, "'#{id}' が見つかりません。 (#{e.message})"
    rescue => e
      raise ExternalServiceError, e.message
    end

    def track_uri(track)
      uri = ItunesUri.parse(track['collectionViewUrl'])
      return nil unless uri.absolute?
      return uri
    end

    def amazon_uri(track)
      amazon = AmazonService.new
      return nil unless asin = amazon.search(create_keyword(track), ['DigitalMusic', 'Music'])
      return amazon.item_uri(asin)
    end

    def spotify_uri(track)
      spotify = SpotifyService.new
      return nil unless track = spotify.search_track(create_keyword(track))
      return spotify.track_uri(track)
    end

    def self.create_tags(names)
      tags = []
      names.strip.split(/[・、]/).each do |part|
        part.sub!(/^(歌|語り):/, '')
        if matches = part.match(/^(.*)\s*\(CV[.:] ?(.*)\)$/i)
          matches[1].split(%r{[/]}).each do |v|
            tags.push(Mastodon.create_tag(v))
          end
          tags.push("CV:#{Mastodon.create_tag(matches[2]).tr('_', '')}")
        else
          tags.push(Mastodon.create_tag(part))
        end
      end
      return tags
    rescue
      return [Mastodon.create_tag(names)]
    end

    private

    def create_keyword(track)
      return [track['trackName'], track['artistName']].join(' ')
    end

    def create_search_uri(keyword, category)
      uri = ItunesUri.parse(@config['application']['itunes']['urls']['search'])
      uri.query_values = {
        term: keyword,
        media: category,
        country: @config['local']['itunes']['country'],
        lang: @config['local']['itunes']['lang'],
      }
      return uri
    end

    def create_lookup_uri(id)
      uri = ItunesUri.parse(@config['application']['itunes']['urls']['lookup'])
      uri.query_values = {
        id: id,
        country: @config['local']['itunes']['country'],
        lang: @config['local']['itunes']['lang'],
      }
      return uri
    end
  end
end