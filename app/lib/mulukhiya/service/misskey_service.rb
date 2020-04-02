require 'digest/sha2'

module Mulukhiya
  class MisskeyService
    include Package
    attr_reader :uri
    attr_reader :token
    attr_accessor :mulukhiya_enable

    def initialize(uri = nil, token = nil)
      @config = Config.instance
      @logger = Logger.new
      @token = token || @config['/agent/test/token']
      @uri = NoteURI.parse(uri || @config['/misskey/url'])
      @mulukhiya_enable = false
      @http = http_class.new
    end

    def mulukhiya_enable?
      return @mulukhiya_enable || false
    end

    alias mulukhiya? mulukhiya_enable?

    def token=(token)
      @token = token
      @account = nil
    end

    def account
      @account ||= Environment.account_class.get(token: @token)
      return @account
    rescue
      return nil
    end

    def note(body, params = {})
      body = {text: body.to_s} unless body.is_a?(Hash)
      headers = params[:headers] || {}
      headers['X-Mulukhiya'] = package_class.full_name unless mulukhiya_enable?
      body[:i] ||= @token
      return @http.post(create_uri, {body: body.to_json, headers: headers})
    end

    alias toot note

    def favourite(id, params = {})
      headers = params[:headers] || {}
      headers['X-Mulukhiya'] = package_class.full_name unless mulukhiya_enable?
      return @http.post(create_uri('/api/notes/favorites/create'), {
        body: {noteId: id, i: @token}.to_json,
        headers: headers,
      })
    end

    alias fav favourite

    def upload(path, params = {})
      headers = params[:headers] || {}
      headers['X-Mulukhiya'] = package_class.full_name unless mulukhiya_enable?
      body = {force: 'true', i: @token}
      return @http.upload(create_uri('/api/drive/files/create'), path, headers, body)
    end

    def upload_remote_resource(uri)
      path = File.join(
        Environment.dir,
        'tmp/media',
        Digest::SHA1.hexdigest(uri),
      )
      File.write(path, @http.get(uri))
      return upload(path)
    ensure
      File.unlink(path) if File.exist?(path)
    end

    def announcements(params = {})
      headers = params[:headers] || {}
      headers['X-Mulukhiya'] = package_class.full_name unless mulukhiya_enable?
      return @http.post(create_uri('/api/announcements'), {
        body: {i: @token}.to_json,
        headers: headers,
      })
    end

    def oauth_client
      unless File.exist?(oauth_client_path)
        body = {
          name: Package.name,
          description: @config['/package/description'],
          permission: @config['/misskey/oauth/permission'],
          callbackUrl: create_uri(@config['/misskey/oauth/callback_url']).to_s,
        }
        r = @http.post(create_uri('/api/app/create'), {body: body.to_json})
        File.write(oauth_client_path, r.parsed_response.to_json)
      end
      return JSON.parse(File.read(oauth_client_path))
    end

    def create_access_token(token)
      return Digest::SHA256.hexdigest(token + oauth_client['secret'])
    end

    def oauth_client_path
      return File.join(Environment.dir, 'tmp/cache/oauth_cilent.json')
    end

    def oauth_uri
      body = {appSecret: oauth_client['secret']}
      r = @http.post(create_uri('/api/auth/session/generate'), {body: body.to_json})
      return Ginseng::URI.parse(r.parsed_response['url'])
    end

    def auth(token)
      body = {
        appSecret: oauth_client['secret'],
        token: token,
      }
      return @http.post(
        create_uri('/api/auth/session/userkey'),
        {body: body.to_json},
      )
    end

    def fetch_note(id)
      response = @http.get(create_uri("/mulukhiya/note/#{id}"))
      raise response.parsed_response['message'] unless response.code == 200
      return response.parsed_response
    end

    def create_uri(href = '/api/notes/create')
      uri = self.uri.clone
      uri.path = href
      return uri
    end

    def notify(account, message)
      return note(
        MisskeyController.status_field => message,
        'visibleUserIds' => [account.id],
        'visibility' => MisskeyController.visibility_name('direct'),
      )
    end

    def self.webhooks
      return enum_for(__method__) unless block_given?
      config = Config.instance
      Misskey::AccessToken.all do |token|
        values = {
          digest: Webhook.create_digest(config['/misskey/url'], token.values[:hash]),
          token: token.values[:hash],
          account: token.account,
        }
        yield values
      end
    end

    def self.create_tag(word)
      return '#' + word.strip.gsub(/[^[:alnum:]]+/, '_').gsub(/(^[_#]+|_$)/, '')
    end
  end
end
