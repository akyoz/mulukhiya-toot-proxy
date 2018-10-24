require 'httparty'
require 'addressable/uri'
require 'rest-client'
require 'digest/sha1'
require 'json'
require 'mulukhiya/package'
require 'mulukhiya/error/external_service'

module MulukhiyaTootProxy
  class Mastodon
    def initialize(url, token)
      @url = Addressable::URI.parse(url)
      @token = token
    end

    def toot(body)
      return HTTParty.post(create_uri('/api/v1/statuses'), {
        body: body.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'User-Agent' => Package.user_agent,
          'Authorization' => "Bearer #{@token}",
          'X-Mulukhiya' => '1',
        },
        ssl_ca_file: ENV['SSL_CERT_FILE'],
      })
    end

    def upload(path)
      response = RestClient.post(
        create_uri('/api/v1/media').to_s,
        {file: File.new(path, 'rb')},
        {
          'User-Agent' => Package.user_agent,
          'Authorization' => "Bearer #{@token}",
        },
      )
      return JSON.parse(response.body)['id'].to_i
    end

    def upload_remote_resource(url)
      path = File.join(ROOT_DIR, 'tmp/media', Digest::SHA1.hexdigest(url))
      File.write(path, fetch(url))
      return upload(path)
    ensure
      File.unlink(path) if File.exist?(path)
    end

    def self.create_tag(word)
      return '#' + word.gsub(/[^[:alnum:]]+/, '_').sub(/^_/, '').sub(/_$/, '')
    end

    private

    def fetch(url)
      return HTTParty.get(url, {
        headers: {
          'User-Agent' => Package.user_agent,
        },
        ssl_ca_file: ENV['SSL_CERT_FILE'],
      })
    rescue => e
      raise ExternalServiceError, "外部ファイルが取得できません。 (#{e.message})"
    end

    def create_uri(href)
      toot_url = @url.clone
      toot_url.path = href
      return toot_url
    end
  end
end
