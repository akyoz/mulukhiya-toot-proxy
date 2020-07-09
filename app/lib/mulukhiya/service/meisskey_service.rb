require 'fileutils'
require 'digest/sha1'

module Mulukhiya
  class MeisskeyService < Ginseng::Fediverse::MeisskeyService
    include Package

    def announcements(params = {})
      headers = params[:headers] || {}
      headers['X-Mulukhiya'] = package_class.full_name unless mulukhiya_enable?
      r = @http.get('/api/meta', {
        body: {i: token}.to_json,
        headers: headers,
      })
      raise Ginseng::GatewayError, "Bad response #{r.code}" unless r.code == 200
      return r['announcements'].map do |entry|
        {
          'id' => Digest::SHA1.hexdigest(entry.to_json),
          'title' => entry['title'],
          'text' => entry['text'],
        }
      end
    end

    def upload(path, params = {})
      if filename = params[:filename]
        dir = File.join(Environment.dir, 'tmp/media/upload', File.basename(path))
        FileUtils.mkdir_p(dir)
        file = MediaFile.new(path)
        filename += file.valid_extname unless file.valid_extname?
        dest = File.join(dir, filename)
        FileUtils.copy(path, dest)
        path = dest
      end
      return super
    ensure
      FileUtils.rm_rf(dir) if dir
    end

    def account
      @account ||= Environment.account_class.get(token: token)
      return @account
    rescue
      return nil
    end

    def access_token
      return Environment.access_token_class.first(hash: token) if token
      return nil
    end

    def oauth_client
      unless client = redis.get('oauth_client')
        r = @http.post('/api/app/create', {
          body: {
            name: package_class.name,
            description: @config['/package/description'],
            permission: @config['/meisskeh/oauth/permission'],
            callbackUrl: @http.create_uri(@config['/meisskeh/oauth/callback_url']).to_s,
          }.to_json,
        })
        raise Ginseng::GatewayError, "Invalid response (#{r.code})" unless r.code == 200
        client = r.body
        redis.set('oauth_client', client)
      end
      return JSON.parse(client)
    end

    def clear_oauth_client
      Redis.new.unlink('oauth_client')
    end

    def redis
      @redis ||= Redis.new
      return @redis
    end

    def notify(account, message, response = nil)
      note = {
        MeisskeyController.status_field => message,
        'visibleUserIds' => [account.id],
        'visibility' => MeisskeyController.visibility_name('direct'),
      }
      note['replyId'] = response['createdNote']['id'] if response
      return post(note)
    end

    private

    def default_token
      return @config['/agent/test/token']
    end
  end
end