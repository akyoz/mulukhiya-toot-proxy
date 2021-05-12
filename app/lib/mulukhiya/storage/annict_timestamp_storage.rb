module Mulukhiya
  class AnnictTimestampStorage < Redis
    def get(key)
      return nil unless entry = super
      return JSON.parse(entry)
    rescue => e
      logger.error(error: e, key: key)
      return nil
    end

    def set(key, values)
      setex(key, ttl, values.to_json)
    end

    def prefix
      return 'annict'
    end
  end
end
