module Mulukhiya
  module Meisskey
    class Attachment < CollectionModel
      def to_h
        unless @hash
          @hash = values.merge(
            'id' => id,
            'acct' => account.acct.to_s,
            'file_name' => name,
            'file_size_str' => size_str,
            'type' => type,
            'subtype' => type.split('/').first,
            'created_at' => date,
            'created_at_str' => date.strftime('%Y/%m/%d %H:%M:%S'),
            'meta' => meta,
            'url' => uri.to_s,
            'thumbnail_url' => values.dig('metadata', 'thumbnailUrl'),
          )
          @hash.delete('_id')
          @hash.delete('metadata')
          @hash.deep_compact!
        end
        return @hash
      end

      def feed_entry
        return {
          link: uri.to_s,
          title: "#{name} (#{size_str}) #{description}",
          author: account.display_name || account.acct.to_s,
          date: date,
        }
      end

      def account
        return Account[values.dig('metadata', 'userId')]
      end

      def type
        return contentType
      end

      def uri
        @uri ||= Ginseng::URI.parse(values['src'] || values.dig('metadata', 'url'))
        return @uri
      end

      def meta
        return values.dig('metadata', 'properties')
      end

      def date
        return values['uploadDate']
      end

      def name
        return values['filename']
      end

      def size
        return values['length']
      end

      def size_str
        ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi', 'Yi'].freeze.each_with_index do |unit, i|
          unitsize = 1024.pow(i)
          return "#{(size.to_f / unitsize).floor.commaize}#{unit}B" if size < unitsize * 1024 * 2
        end
        raise 'Too large'
      end

      def self.[](id)
        return Attachment.new(id)
      end

      def self.logger
        return Logger.new
      end

      def self.catalog
        return enum_for(__method__) unless block_given?
        cnt = 0
        statuses.each do |row|
          note = Status[row[:_id]]
          note.attachments.each do |attachment|
            break unless cnt < config['/feed/media/limit']
            attachment = Attachment[attachment['id']]
            yield attachment.to_h.deep_symbolize_keys.merge(
              date: note.createdAt,
              status_url: note.uri.to_s,
            )
            cnt += 1
          end
        rescue => e
          logger.error(error: e, row: row.to_h)
        end
      end

      def self.feed
        return enum_for(__method__) unless block_given?
        cnt = 0
        statuses.each do |row|
          note = Status[row[:_id]]
          note.attachments.each do |attachment|
            break unless cnt < config['/feed/media/limit']
            yield Attachment[attachment['id']].feed_entry
          end
        rescue => e
          logger.error(error: e, row: row.to_h)
        end
      end

      def self.config
        return Config.instance
      end

      def self.statuses
        user_ids = (config['/feed/test_usernames'] || []).map do |id|
          BSON::ObjectId.from_string(Account.get(username: id).id)
        end
        rows = Status.collection
          .find(
            fileIds: {'$ne' => []},
            userId: {'$nin' => user_ids},
            _user: {'host': nil, 'inbox': nil}, # local
            visibility: {'$in' => ['public', 'home']},
          )
          .sort(createdAt: -1)
          .limit(config['/feed/media/limit'])
        return rows
      end

      def self.collection
        return Mongo.instance.db['driveFiles.files']
      end

      private

      def collection_name
        return 'driveFiles.files'
      end
    end
  end
end
