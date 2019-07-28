module MulukhiyaTootProxy
  class Server < Ginseng::Web::Sinatra
    include Package
    set :root, Environment.dir

    def before_post
      super
      @mastodon = Mastodon.new
      @results = ResultContainer.new
      return unless @headers['HTTP_AUTHORIZATION']
      @mastodon.token = @headers['HTTP_AUTHORIZATION'].split(/\s+/)[1]
    end

    post '/api/v1/statuses' do
      tags = TagContainer.scan(params[:status])
      Handler.exec_all(:pre_toot, params, {results: @results, mastodon: @mastodon})
      @results.response = @mastodon.toot(params)
      Handler.exec_all(:post_toot, params, {results: @results})
      @renderer.message = @results.response.parsed_response
      @renderer.message['results'] = @results.summary
      @renderer.message['tags']&.keep_if{|v| tags.include?(v['name'])}
      @renderer.status = @results.response.code
      return @renderer.to_s
    end

    post '/api/v1/media' do
      Handler.exec_all(:pre_upload, params, {results: @results, mastodon: @mastodon})
      @results.response = @mastodon.upload(params[:file][:tempfile].path, {response: :raw})
      Handler.exec_all(:post_upload, params, {results: @results})
      @renderer.message = JSON.parse(@results.response.body)
      @renderer.message['results'] = @results.summary
      @renderer.status = @results.response.code
      return @renderer.to_s
    rescue RestClient::UnprocessableEntity => e
      @renderer.message = JSON.parse(e.response.body)
      @renderer.status = e.response.code
      return @renderer.to_s
    end

    post '/api/v1/statuses/:id/favourite' do
      @results.response = @mastodon.fav(params[:id])
      Handler.exec_all(:post_fav, params, {results: @results})
      @renderer.message = @results.response.parsed_response
      @renderer.message['results'] = @results.summary
      @renderer.status = @results.response.code
      return @renderer.to_s
    end

    post '/api/v1/statuses/:id/reblog' do
      @results.response = @mastodon.boost(params[:id])
      Handler.exec_all(:post_boost, params, {results: @results})
      @renderer.message = @results.response.parsed_response
      @renderer.message['results'] = @results.summary
      @renderer.status = @results.response.code
      return @renderer.to_s
    end

    post '/mulukhiya/webhook/:digest' do
      errors = WebhookContract.new.call(params).errors.to_h
      if errors.present?
        @renderer.status = 422
        @renderer.message = errors
      elsif webhook = Webhook.create(params[:digest])
        results = webhook.toot(params)
        @renderer.message = results.response.parsed_response
        @renderer.message['results'] = results.summary
        @renderer.status = results.response.code
      else
        @renderer.status = 404
      end
      return @renderer.to_s
    end

    get '/mulukhiya/webhook/:digest' do
      if Webhook.create(params[:digest])
        @renderer.message = {message: 'OK'}
      else
        @renderer.status = 404
      end
      return @renderer.to_s
    end

    get '/mulukhiya/app/auth' do
      @renderer = HTMLRenderer.new
      @renderer.template = 'app_auth'
      @renderer['oauth_url'] = Mastodon.new.oauth_uri
      return @renderer.to_s
    end

    post '/mulukhiya/app/auth' do
      @renderer = HTMLRenderer.new
      errors = AppAuthContract.new.call(params).errors.to_h
      if errors.present?
        @renderer.template = 'app_auth'
        @renderer['errors'] = errors
        @renderer['oauth_url'] = Mastodon.new.oauth_uri
      else
        r = Mastodon.new.auth(params[:code])
        @renderer.template = 'app_auth_result'
        @renderer['status'] = r.code
        @renderer['result'] = r.parsed_response
        @renderer.status = r.code
      end
      return @renderer.to_s
    end

    get '/mulukhiya/style/:style' do
      @renderer = CSSRenderer.new
      @renderer.template = params[:style]
      return @renderer.to_s
    rescue Ginseng::RenderError
      @renderer.status = 404
    end

    not_found do
      @renderer = Ginseng::Web::JSONRenderer.new
      @renderer.status = 404
      @renderer.message = Ginseng::NotFoundError.new("Resource #{request.path} not found.").to_h
      return @renderer.to_s
    end

    error do |e|
      e = Ginseng::Error.create(e)
      e.package = Package.full_name
      @renderer = Ginseng::Web::JSONRenderer.new
      @renderer.status = e.status
      @renderer.message = e.to_h.delete_if{|k, v| k == :backtrace}
      @renderer.message['error'] = e.message
      Slack.broadcast(e)
      @logger.error(e)
      return @renderer.to_s
    end
  end
end
