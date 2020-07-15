module Mulukhiya
  module Meisskey
    class AccessToken < CollectionModel
      def valid?
        return account && token && application.name == Package.name
      end

      def to_h
        unless @hash
          @hash = values.clone
          @hash.delete('token')
          @hash.merge!(
            digest: webhook_digest,
            token: to_s,
            account: account,
            scopes: scopes,
          )
          @hash.compact!
        end
        return @hash
      end

      alias to_s hash

      def hash
        return values['hash']
      end

      def account
        return Account.new(values['userId'])
      end

      def application
        return Application.new(values['appId'])
      end

      def scopes
        return application.permission
      end

      def webhook_digest
        return Webhook.create_digest(Config.instance['/meisskey/url'], to_s)
      end

      def self.[](id)
        return AccessToken.new(id)
      end

      def self.get(key)
        return nil if key[:hash].nil?
        token = collection.find(hash: key[:hash]).first
        return AccessToken.new(token['_id'])
      end

      def self.first(key)
        return get(key)
      end

      def self.all
        return enum_for(__method__) unless block_given?
        collection.find.each do |token|
          yield AccessToken.new(token['_id'])
        end
      end

      def self.collection
        return Mongo.instance.db[:accessTokens]
      end

      private

      def collection_name
        return :accessTokens
      end
    end
  end
end
