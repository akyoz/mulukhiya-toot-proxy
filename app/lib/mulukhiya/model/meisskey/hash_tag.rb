module Mulukhiya
  module Meisskey
    class HashTag < CollectionModel
      def name
        return values['tag']
      end

      def uri
        @uri ||= Environment.sns_class.new.create_uri("/tags/#{name}")
        return @uri
      end

      def create_feed(params)
        return [] unless Mongo.config?
        user_ids = (params[:test_usernames] || []).map do |id|
          BSON::ObjectId.from_string(Account.get(username: id).id)
        end
        notes = Status.collection
          .find(tags: name, userId: {'$nin' => user_ids})
          .sort(createdAt: -1)
          .limit(params[:limit])
        return notes.map do |row|
          status = Status.new(row['_id'])
          {
            username: status.account.username,
            domain: status.account.acct.host,
            display_name: status.account.name,
            spoiler_text: status.cw,
            text: status.text,
            uri: status.uri.to_s,
            created_at: status.createdAt,
          }
        end
      end

      def self.[](id)
        return HashTag.new(id)
      end

      def self.get(key)
        return nil if key[:tag].nil?
        tag = collection.find(tag: key[:tag]).first
        return HashTag.new(tag['_id'])
      end

      def self.first(key)
        return get(key)
      end

      def self.collection
        return Mongo.instance.db[:hashtags]
      end

      private

      def collection_name
        return :hashtags
      end
    end
  end
end