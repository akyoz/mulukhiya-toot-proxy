module Mulukhiya
  module AccessTokenMethods
    def logger
      @logger ||= Logger.new
      return @logger
    end

    def config
      return Config.instance
    end

    def webhook_digest
      return Webhook.create_digest(Environment.sns_class.new.uri, to_s)
    end

    def self.included(base)
      base.extend(Methods)
    end

    module Methods
      def logger
        return Logger.new
      end

      def config
        return Config.instance
      end
    end
  end
end
