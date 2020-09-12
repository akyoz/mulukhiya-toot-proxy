module Mulukhiya
  module Mastodon
    class HashTag < Sequel::Model(:tags)
      def uri
        @uri ||= Environment.sns_class.new.create_uri("/tags/#{name}")
        return @uri
      end

      alias to_h values

      def create_feed(params)
        return [] unless Postgres.config?
        params[:tag] = name
        return Postgres.instance.execute('tag_feed', params)
      end

      def self.get(key)
        return HashTag.first(name: key[:tag]) if key.key?(:tag)
        return HashTag.first(key)
      end
    end
  end
end