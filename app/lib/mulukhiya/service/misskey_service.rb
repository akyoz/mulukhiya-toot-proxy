require 'fileutils'

module Mulukhiya
  class MisskeyService < Ginseng::Fediverse::MisskeyService
    include Package
    attr_reader :token

    def initialize(uri = nil, token = nil)
      @config = Config.instance
      token ||= @config['/agent/test/token']
      super
    end

    def token=(token)
      @token = token
      @account = nil
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

    def filters
      return nil
    end

    def account
      @account ||= Environment.account_class.get(token: @token)
      return @account
    rescue
      return nil
    end

    def access_token
      return Environment.access_token_class.first(hash: @token) if token
      return nil
    end

    def clear_oauth_client
      File.unlink(oauth_client_path) if File.exist?(oauth_client_path)
    end

    def notify(account, message)
      return note(
        MisskeyController.status_field => message,
        'visibleUserIds' => [account.id],
        'visibility' => MisskeyController.visibility_name('direct'),
      )
    end
  end
end
