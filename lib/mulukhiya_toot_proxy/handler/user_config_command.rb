module MulukhiyaTootProxy
  class UserConfigCommandHandler < CommandHandler
    def dispatch(values)
      raise Ginseng::GatewayError, 'Invalid access token' unless id = mastodon.account_id
      UserConfigStorage.new.update(id, values)
    end

    def create_status(values)
      return YAML.dump(
        JSON.parse(UserConfigStorage.new.get(mastodon.account_id)),
      )
    rescue => e
      raise Ginseng::RequestError, e.message
    end
  end
end
