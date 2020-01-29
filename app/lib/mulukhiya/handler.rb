require 'timeout'
require 'httparty'
require 'rest-client'

module Mulukhiya
  class Handler
    attr_accessor :tags
    attr_accessor :results
    attr_reader :sns
    attr_reader :local_tags

    def handle_pre_toot(body, params = {})
      return body
    end

    def handle_post_toot(body, params = {}); end

    def handle_pre_webhook(body, params = {})
      handle_pre_toot(body, params)
    end

    def handle_post_webhook(body, params = {})
      handle_post_toot(body, params)
    end

    def handle_pre_upload(body, params = {}); end

    def handle_post_upload(body, params = {}); end

    def handle_post_fav(body, params = {}); end

    def handle_post_boost(body, params = {}); end

    def handle_post_bookmark(body, params = {}); end

    def handle_post_search(body, params = {}); end

    def underscore_name
      return self.class.to_s.split('::').last.sub(/Handler$/, '').underscore
    end

    def summary
      return "#{self.class.to_s.split('::').last},#{@result.count}"
    end

    def result
      return nil unless @result.present?
      return {
        controller: Environment.controller_class.to_s,
        handler: self.class.to_s,
        event: @event,
        entries: @result,
      }
    end

    def clear
      @tags.clear
      @result.clear
      @status = nil
      @parser = nil
      @local_tags.clear
      @prepared = false
      @results.clear
      @results.parser = nil
    end

    def timeout
      return @config["/handler/#{underscore_name}/timeout"]
    rescue Ginseng::ConfigError
      return @config['/handler/default/timeout']
    end

    def prepared?
      return @repared.present?
    end

    def disable?
      return true unless Postgres.config?
      return true if sns.account.disable?(underscore_name)
      return true if @config.disable?(underscore_name)
      return false
    rescue Ginseng::ConfigError, Ginseng::DatabaseError
      return false
    end

    alias disabled? disable?

    def parser
      unless @parser
        @parser = @results.parser || Environment.parser_class.new(@status)
        @results.parser = @parser
      end
      return @parser
    end

    def status_field
      return Environment.controller_class.status_field
    end

    def status_key
      return Environment.controller_class.status_key
    end

    def attachment_key
      return Environment.controller_class.attachment_key
    end

    def self.create(name, params = {})
      return "Mulukhiya::#{name.camelize}Handler".constantize.new(params)
    rescue Ginseng::ConfigError
      return nil
    end

    def self.all(event, params = {})
      config = Config.instance
      unless config["#{Environment.controller_name}/events"].member?(event)
        raise "Invalid event '#{event}'"
      end
      config["/#{Environment.controller_name}/handlers/#{event}"].each do |v|
        yield create(v, params)
      end
    end

    def self.exec_all(event, body, params = {})
      params[:event] = event
      params[:results] ||= ResultContainer.new
      params[:tags] ||= TagContainer.new
      all(event, params) do |handler|
        next if handler.disable?
        Timeout.timeout(handler.timeout) do
          handler.send("handle_#{event}".to_sym, body, params)
        end
        params[:results].push(handler.result)
        params[:tags].concat(handler.local_tags)
        break if handler.prepared?
      rescue Timeout::Error => e
        Logger.new.error(e)
      rescue RestClient::Exception, HTTParty::Error => e
        raise Ginseng::GatewayError, e.message, e.backtrace
      end
      return params[:results]
    end

    private

    def initialize(params = {})
      @config = Config.instance
      @logger = Logger.new
      @result = []
      @local_tags = []
      @sns = params[:sns] || Environment.sns_class.new
      @tags = params[:tags] || TagContainer.new
      @results = params[:results] || ResultContainer.new
      @prepared = false
      @event = params[:event] || 'unknown'
    end
  end
end
