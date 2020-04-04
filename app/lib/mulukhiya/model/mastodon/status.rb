module Mulukhiya
  module Mastodon
    class Status < Sequel::Model(:statuses)
      one_to_many :attachment
      many_to_one :account

      def logger
        @logger ||= Logger.new
        return @logger
      end

      alias local? local

      alias attachments attachment

      def uri
        unless @uri
          @uri = TootURI.parse(self[:url] || self[:uri])
          @uri = NoteURI.parse(self[:url] || self[:uri]) unless @uri&.valid?
          @uri = nil unless @uri&.valid?
        end
        return @uri
      end

      alias to_h values

      def to_md
        return uri.to_md
      rescue => e
        logger.error(e)
        template = Template.new('toot_clipping.md')
        template[:account] = account.to_h
        template[:status] = TootParser.new(text).to_md
        template[:url] = uri.to_s
        return template.to_s
      end
    end
  end
end
