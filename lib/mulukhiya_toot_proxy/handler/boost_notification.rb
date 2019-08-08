module MulukhiyaTootProxy
  class BoostNotificationHandler < NotificationHandler
    def notifiable?(body)
      return false unless toot = Toot.new(id: body['id'].to_i)
      return false unless toot.local?
      return true
    rescue Ginseng::NotFoundError
      return false
    end

    def handle_post_boost(body, params = {})
      return unless notifiable?(body)
      worker_class.perform_async(
        account_id: mastodon.account.id,
        status_id: body['id'].to_i,
      )
      @result.push(status_id: body['id'].to_i)
    end
  end
end