require 'omniauth'
require 'omniauth-twitter'

module Mulukhiya
  class Controller < Ginseng::Web::Sinatra
    include Package
    set :root, Environment.dir
    enable :sessions

    use OmniAuth::Builder do
      config = Config.instance
      provider :twitter, config['/twitter/consumer/key'], config['/twitter/consumer/secret']
    end

    before do
      @reporter = Reporter.new
    end

    get '/mulukhiya' do
      @renderer = SlimRenderer.new
      @renderer.template = 'home'
      return @renderer.to_s
    end

    post '/mulukhiya/webhook/:digest' do
      errors = WebhookContract.new.call(params).errors.to_h
      if errors.present?
        @renderer.status = 422
        @renderer.message = errors
      elsif webhook = Webhook.create(params[:digest])
        reporter = webhook.post(params)
        @renderer.message = reporter.response.parsed_response
        @renderer.status = reporter.response.code
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

    get '/mulukhiya/about' do
      @renderer.message = {package: @config.raw.dig('application', 'package')}
      return @renderer.to_s
    end

    get '/mulukhiya/config' do
      if @sns.account
        @renderer.message = {
          account: @sns.account.to_h,
          config: @sns.account.config.to_h,
          filters: @sns.filters&.parsed_response,
          token: @sns.access_token.to_h,
        }
      else
        @renderer.message = {error: 'Invalid token'}
        @renderer.status = 403
      end
      return @renderer.to_s
    end

    post '/mulukhiya/config' do
      Handler.create('user_config_command').handle_toot(params, {sns: @sns})
      @renderer.message = {
        account: @sns.account.to_h,
        config: @sns.account.config.to_h,
        filters: @sns.filters&.parsed_response,
        token: @sns.access_token.to_h,
      }
      return @renderer.to_s
    rescue Ginseng::AuthError, Ginseng::ValidateError => e
      @renderer.message = {error: e.message}
      @renderer.status = e.status
      return @renderer.to_s
    end

    get '/mulukhiya/programs' do
      path = File.join(Environment.dir, 'tmp/cache/programs.json')
      if File.readable?(path)
        @renderer.message = JSON.parse(File.read(path))
      else
        @renderer.message = []
      end
      return @renderer.to_s
    end

    get '/mulukhiya/app/config' do
      @renderer = SlimRenderer.new
      @renderer.template = 'config'
      return @renderer.to_s
    end

    get '/mulukhiya/app/auth' do
      @renderer = SlimRenderer.new
      @renderer.template = 'auth'
      @renderer[:oauth_url] = @sns.oauth_uri
      return @renderer.to_s
    end

    get '/mulukhiya/app/token' do
      @renderer = SlimRenderer.new
      @renderer.template = 'token'
      return @renderer.to_s
    end

    get '/mulukhiya/health' do
      @renderer.message = Environment.health
      @renderer.status = @renderer.message[:status] || 200
      return @renderer.to_s
    end

    get '/mulukhiya/app/health' do
      @renderer = SlimRenderer.new
      @renderer.template = 'health'
      return @renderer.to_s
    end

    get '/mulukhiya/style/:style' do
      @renderer = CSSRenderer.new
      @renderer.template = params[:style]
      return @renderer.to_s
    rescue Ginseng::RenderError
      @renderer.status = 404
    end

    get '/auth/twitter/callback' do
      errors = TwitterAuthContract.new.call(params).errors.to_h
      if errors.present?
        @renderer.status = 422
        @renderer.message = errors
      elsif @sns.account
        @sns.account.config.update(twitter: {
          token: params[:oauth_token],
          verifier: params[:oauth_verifier],
        })
        @renderer = SlimRenderer.new
        @renderer.template = 'config'
      else
        @renderer.status = 403
      end
      return @renderer.to_s
    end

    def response_error?
      return 400 <= @reporter.response&.code
    end

    def notify(message)
      message = message.to_yaml unless message.is_a?(String)
      return Environment.info_agent_service&.notify(@sns.account, message)
    end

    not_found do
      @renderer = default_renderer_class.new
      @renderer.status = 404
      @renderer.message = Ginseng::NotFoundError.new("Resource #{request.path} not found.").to_h
      return @renderer.to_s
    end

    error do |e|
      e = Ginseng::Error.create(e)
      e.package = Package.full_name
      @renderer = default_renderer_class.new
      @renderer.status = e.status
      @renderer.message = e.to_h
      @renderer.message.delete(:backtrace)
      @renderer.message[:error] = e.message
      Slack.broadcast(e)
      @logger.error(e)
      return @renderer.to_s
    end
  end
end
