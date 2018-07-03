require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require 'httparty'
require 'addressable/uri'
require 'mulukhiya/config'
require 'mulukhiya/slack'
require 'mulukhiya/package'
require 'mulukhiya/logger'
require 'mulukhiya/json_renderer'
require 'mulukhiya/handler'

module MulukhiyaTootProxy
  class Server < Sinatra::Base
    def initialize
      super
      @config = Config.instance
      @logger = Logger.new
      @logger.info({
        message: 'starting...',
        server: {port: @config['thin']['port']},
      })
    end

    before do
      @message = {request: {path: request.path, params: params}, response: {}}
      @renderer = JSONRenderer.new
      @headers = request.env.select{ |k, v| k.start_with?('HTTP_')}
      @result = []
      begin
        @params = JSON.parse(request.body.read.to_s)
      rescue
        @params = params
      end
      @message[:request][:params] = @params
    end

    after do
      @message[:response][:status] ||= @renderer.status
      if @renderer.status < 400
        @logger.info(@message.select{ |k, v| [:request, :response, :package].member?(k)})
      else
        @logger.error(@message)
      end
      status @renderer.status
      content_type @renderer.type
    end

    get '/about' do
      @message[:response][:message] = Package.full_name
      @renderer.message = @message
      return @renderer.to_s
    end

    post '/api/v1/statuses' do
      response = HTTParty.post(toot_url, {
        body: toot_body,
        headers: toot_request_headers,
      })
      @message[:response][:result] = @result
      @message.merge!(JSON.parse(response.to_s))
      @renderer.message = @message
      headers({
        'X-Mulukhiya' => @result.join(', '),
      })
      return @renderer.to_s
    end

    not_found do
      @renderer = JSONRenderer.new
      @renderer.status = 404
      @message[:response][:error] = "Resource #{@message[:request][:path]} not found."
      @renderer.message = @message
      return @renderer.to_s
    end

    error do |e|
      @renderer = JSONRenderer.new
      @renderer.status = 500
      @message[:response][:error] = "#{e.class}: #{e.message}"
      @message[:backtrace] = e.backtrace[0..5]
      @renderer.message = @message
      Slack.all.map{ |h| h.say(@message)}
      return @renderer.to_s
    end

    private

    def toot_url
      url = Addressable::URI.parse(@config['local']['instance_url'])
      url.path = '/api/v1/statuses'
      return url
    rescue
      return Addressable::URI.parse("https://#{@headers['HTTP_HOST']}/api/v1/statuses")
    end

    def toot_body
      body = @params.clone
      Handler.all do |handler|
        handler.exec(body, @headers)
        @result.push(handler.result)
      end
      return body.to_json
    end

    def toot_request_headers
      return {
        'Content-Type' => 'application/json',
        'User-Agent' => "#{@headers['HTTP_USER_AGENT']} +#{Package.full_name}",
        'Authorization' => "Bearer #{@headers['HTTP_AUTHORIZATION'].split(/\s+/)[1]}",
        'X-Mulukhiya' => @result.join(', '),
      }
    end
  end
end