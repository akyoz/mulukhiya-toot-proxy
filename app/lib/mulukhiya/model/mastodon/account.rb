module Mulukhiya
  module Mastodon
    class Account < Sequel::Model(:accounts)
      include AccountMethods
      one_to_one :user
      attr_accessor :token

      def to_h
        unless @hash
          @hash = values.deep_symbolize_keys.merge(
            is_admin: admin?,
            is_moderator: moderator?,
          )
          @hash[:display_name] = acct.to_s if @hash[:display_name].empty?
          @hash.delete(:private_key)
          @hash.delete(:public_key)
          @hash.deep_compact!
        end
        return @hash
      end

      def domain
        return values[:domain] || Environment.domain_name
      end

      alias host domain

      def recent_status
        rows = Postgres.instance.exec('recent_toot', {id: id})
        return Status[rows.first['id']] if rows.present?
        return nil
      end

      alias recent_toot recent_status

      def featured_tag_bases
        response = service.fetch_featured_tags(id)
        return response.parsed_response.map {|v| v['name'].to_hashtag_base}
      rescue
        return []
      end

      def admin?
        return user.admin
      end

      def moderator?
        return user.moderator
      end

      def service?
        return actor_type == 'Service'
      end

      alias bot? service?

      alias locked? locked

      def self.get(key)
        if key.key?(:token)
          return nil if key[:token].nil?
          account = Postgres.instance.exec('token_owner', {token: key[:token]})&.first
          account = Account[account[:id]]
          account.token = key[:token]
          return account
        elsif acct = key[:acct]
          acct = Acct.new(acct.to_s) unless acct.is_a?(Acct)
          return Account.first(username: acct.username, domain: acct.domain)
        end
        return Account.first(key)
      end
    end
  end
end
