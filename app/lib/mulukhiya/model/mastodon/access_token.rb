module Mulukhiya
  module Mastodon
    class AccessToken < Sequel::Model(:oauth_access_tokens)
      many_to_one :account, key: :resource_owner_id
      many_to_one :application, key: :application_id

      def valid?
        return false unless to_s.present?
        return false unless account
        return false if expires_in.present?
        return false if revoked_at.present?
        return application.name == Package.name
      end

      def webhook_digest
        return Webhook.create_digest(Environment.sns_class.new.uri, to_s)
      end

      alias to_s token

      def scopes
        return values[:scopes].split(/\s+/)
      end

      def to_h
        unless @hash
          @hash = values.clone
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
    end
  end
end
