require 'mulukhiya/config'
require 'mulukhiya/logger'
require 'mulukhiya/slack'
require 'mulukhiya/error/imprement'

module MulukhiyaTootProxy
  class Handler
    attr_accessor :mastodon

    def initialize
      @config = Config.instance
      @count = 0
    end

    def exec(body, headers = {})
      raise ImprementError, 'execが未定義です。'
    end

    def result
      return "#{self.class.to_s.split('::').last},#{@count}"
    end

    def self.all
      return enum_for(__method__) unless block_given?
      Config.validate('/local/handlers')
      Config.instance['local']['handlers'].each do |handler|
        require "mulukhiya/handler/#{handler}"
        yield "MulukhiyaTootProxy::#{handler.camelize}Handler".constantize.new
      end
    end

    private

    def increment!
      @count += 1
    end
  end
end
