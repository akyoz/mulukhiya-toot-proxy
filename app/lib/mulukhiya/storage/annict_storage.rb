module Mulukhiya
  class AnnictStorage < Redis
    def [](key)
      return get(key) || {}
    end

    def []=(key, value)
      set(key, value)
    end

    def get(key)
      return nil unless entry = super(create_key(key))
      return JSON.parse(entry)
    rescue => e
      @logger.error(Ginseng::RedisError, e.message)
      return nil
    end

    def set(key, values)
      super(create_key(key), values.to_json)
    end

    def all_keys
      return keys('annict:*')
    end

    def create_key(key)
      return "annict:#{key}"
    end

    def self.accounts
      return enum_for(__method__) unless block_given?
      storage = UserConfigStorage.new
      storage.all_keys.each do |key|
        id = key.split(':').last
        next unless storage[id]['/annict/token']
        id = id.to_i if id.match?(/^[[:digit:]]+$/)
        account = Environment.account_class[id]
        next unless account.webhook
        next unless account.annict
        yield account
      end
    end
  end
end
