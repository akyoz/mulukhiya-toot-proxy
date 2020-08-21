module Mulukhiya
  class UserConfigCommandHandler < CommandHandler
    def disable?
      return true unless Environment.dbms_class.config?
      return false
    end

    def handle_post_toot(body, params = {})
      super
      return unless parser.command_name == command_name
      notify(sns.account.config.to_h) if sns.account.config['/notify/user_config']
    end

    def command_params
      params = parser.params.clone
      params['tags'] ||= []
      params['webhook'] ||= {}
      params['growi'] ||= {}
      params['dropbox'] ||= {}
      params['notify'] ||= {}
      params['amazon'] ||= {}
      params['annict'] ||= {}
      return params
    end

    def exec
      raise Ginseng::AuthError, 'Invalid token' unless sns.account
      sns.account.config.update(parser.params)
    end
  end
end
