module Mulukhiya
  class PleromaService < Ginseng::Fediverse::PleromaService
    include Package
    include SNSMethods
    include SNSServiceMethods

    alias info nodeinfo

    def upload(path, params = {})
      if filename = params[:filename]
        dir = File.join(Environment.dir, 'tmp/media/upload', path.adler32.to_s)
        FileUtils.mkdir_p(dir)
        file = MediaFile.new(path)
        dest = File.basename(filename, File.extname(filename)) + file.recommended_extname
        dest = File.join(dir, dest)
        FileUtils.copy(path, dest)
        path = dest
      end
      params[:trim_times].times {ImageFile.new(path).trim!} if params&.dig(:trim_times)
      return super
    ensure
      FileUtils.rm_rf(dir) if dir
    end

    def delete_attachment(attachment, params = {})
      attachment = attachment_class[attachment] if attachment.is_a?(String)
      return delete_status(attachment.status, params)
    end

    def search_status_id(status)
      case status.class.to_s
      when status_class.to_s
        status = status.id
      when 'Ginseng::URI', 'TootURI'
        response = @http.get(status, {follow_redirects: false})
        status = response.headers['location'].match(%r{/notice/(.*)})[1]
      end
      return super
    end

    def oauth_client
      unless client = redis['oauth_client']
        client = http.post('/api/v1/apps', {
          body: {
            client_name: package_class.name,
            website: config['/package/url'],
            redirect_uris: config['/pleroma/oauth/redirect_uri'],
            scopes: PleromaController.oauth_scopes.join(' '),
          },
        }).body
        redis['oauth_client'] = client
      end
      return JSON.parse(client)
    end

    def oauth_uri
      uri = create_uri('/oauth/authorize')
      uri.query_values = {
        client_id: oauth_client['client_id'],
        response_type: 'code',
        redirect_uri: @config['/pleroma/oauth/redirect_uri'],
        scope: PleromaController.oauth_scopes.join(' '),
      }
      return uri
    end

    def notify(account, message, response = nil)
      message = [account.acct.to_s, message.clone].join("\n")
      message.ellipsize!(TootParser.new.max_length)
      status = {
        PleromaController.status_field => message,
        'visibility' => PleromaController.visibility_name('direct'),
      }
      status['in_reply_to_id'] = response['id'] if response
      return post(status)
    end

    def default_token
      return account_class.test_token
    end
  end
end
