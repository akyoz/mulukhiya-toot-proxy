module Mulukhiya
  class UserConfig
    include Package
    include SNSMethods

    def initialize(account)
      @account = account if account.is_a?(account_class)
      if account.is_a?(Hash) && (token = account['/mulukhiya/token'])
        @account ||= account_class.get(token: token)
      end
      @account ||= account_class[account]
      @storage = UserConfigStorage.new
      @values = @storage[@account.id]
    end

    def raw
      return JSON.parse(@storage.get(@account.id))
    end

    def [](key)
      return @values[key]
    end

    def update(values)
      @storage.update(@account.id, values)
      @values = @storage[@account.id]
    end

    def token
      return self['/mulukhiya/token'] || self['/webhook/token']
    end

    def token=(token)
      update(
        webhook: {token: nil},
        mulukhiya: {token: token},
      )
    end

    def tags
      return self['/tagging/user_tags']
    end

    def clear_tags
      update(tagging: {user_tags: nil})
    end

    alias to_h raw

    def disable?(handler)
      handler = Handler.create(handler.to_s) unless handler.is_a?(Handler)
      return @values["/handler/#{handler.underscore}/disable"] == true rescue false
    end
  end
end
