module Mulukhiya
  module Pleroma
    class Status
      attr_reader :data

      def initialize(id)
        @data = PleromaService.new.fetch_status(id).parsed_response
      end

      def acct
        unless @acct
          @acct = Acct.new(data['account']['acct'])
          @acct.host ||= Environment.domain_name
        end
        return @acct
      end

      def account
        @account ||= Account.get(acct: acct)
        return @account
      end

      def text
        return data['content']
      end

      def uri
        @uri ||= TootURI.parse(data['url'])
        return @uri
      end

      def attachments
        return data['media_attachments']
      end

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

      alias to_h data

      def self.[](id)
        return Status.new(id)
      end
    end
  end
end