module Mulukhiya
  class AmazonItemStorage < Redis
    def [](key)
      return get(key)
    end

    def []=(key, value)
      set(key, value)
    end

    def get(key)
      return nil unless entry = super(create_key(key))
      return JSON.parse(entry)
    rescue => e
      @logger.error(error: e.message, key: key)
      return nil
    end

    def set(key, values)
      setex(create_key(key), ttl, values.to_json)
    end

    def ttl
      return [@config['/amazon/cache/ttl'], 86_400].min
    end

    def prefix
      return 'amazon'
    end
  end
end