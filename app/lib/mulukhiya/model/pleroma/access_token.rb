module Mulukhiya
  module Pleroma
    class AccessToken < Sequel::Model(:oauth_tokens)
      many_to_one :account, key: :user_id
      many_to_one :application, key: :app_id

      def valid?
        return false unless to_s.present?
        return false unless account
        return application.name == Package.name
      end

      def webhook_digest
        return Webhook.create_digest(Environment.sns_class.new.uri, to_s)
      end

      alias to_s token

      def to_h
        unless @hash
          @hash = values.clone.compact
          @hash.merge!(
            digest: webhook_digest,
            token: to_s,
            account: account,
            scopes: scopes,
          )
        end
        return @hash
      end
    end
  end
end
