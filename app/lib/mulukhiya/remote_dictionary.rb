module Mulukhiya
  class RemoteDictionary
    def parse
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def fetch
      response = @http.get(uri).parsed_response
      raise 'empty' unless response.present?
      return response
    rescue => e
      raise Ginseng::GatewayError, "Invalid URL '#{uri}'", e.backtrace
    end

    def uri
      @uri ||= Ginseng::URI.parse(@params['/url'])
      return @uri
    end

    def self.all
      return enum_for(__method__) unless block_given?
      Config.instance['/tagging/dictionaries'].each do |dic|
        yield RemoteDictionary.create(dic)
      end
    end

    def self.create(params)
      params['type'] ||= 'multi_field'
      return "Mulukhiya::#{params['type'].camelize}RemoteDictionary".constantize.new(params)
    end

    private

    def create_key(word)
      return word.nfkc
    end

    def create_pattern(word)
      pattern = word.nfkc.gsub(/[^[:alnum:]]/, '.? ?')
      [
        'あぁ', 'いぃ', 'うぅ', 'えぇ', 'おぉ', 'やゃ', 'ゆゅ', 'よょ',
        'アァ', 'イィ', 'ウゥ', 'エェ', 'オォ', 'ヤャ', 'ユュ', 'ヨョ'
      ].each do |v|
        pattern.gsub!(Regexp.new("[#{v}]"), "[#{v}]")
      end
      return Regexp.new(pattern)
    end

    def initialize(params)
      @params = params.key_flatten
      @logger = Logger.new
      @http = HTTP.new
    end
  end
end