module Mulukhiya
  module SNSMethods
    def controller_class
      return Environment.controller_class
    end

    def sns_class
      return Environment.sns_class
    end

    def parser_class
      return Environment.parser_class
    end

    def status_field
      return controller_class.status_field
    end

    def status_key
      return controller_class.status_key
    end

    def attachment_field
      return controller_class.attachment_field
    end

    def attachment_limit
      return controller_class.attachment_limit
    end

    def account_class
      return Environment.account_class
    end

    def status_class
      return Environment.status_class
    end

    def attachment_class
      return Environment.attachment_class
    end

    def access_token_class
      return Environment.access_token_class
    end

    def hash_tag_class
      return Environment.hash_tag_class
    end

    def create_status_uri(src)
      dest = TootURI.parse(src.to_s)
      dest = NoteURI.parse(dest) unless dest&.valid?
      return dest if dest.valid?
    end

    def notify(message, response = nil)
      message = message.to_yaml unless message.is_a?(String)
      return info_agent_service.notify(@sns.account, message, response)
    rescue => e
      logger.error(error: e, message: message)
    end

    def info_agent_service
      service = Environment.sns_service_class.new
      service.token = account_class.info_token
      return service
    end

    def test_account
      return account_class.test_account
    rescue => e
      logger.error(error: e)
    end

    def self.included(base)
      base.extend(Methods)
    end

    module Methods
      def controller_class
        return Environment.controller_class
      end

      def sns_class
        return Environment.sns_class
      end

      def info_agent_service
        service = Environment.sns_service_class.new
        service.token = Environment.account_class.info_token
        return service
      end
    end
  end
end
