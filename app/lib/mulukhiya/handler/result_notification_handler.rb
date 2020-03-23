module Mulukhiya
  class ResultNotificationHandler < Handler
    def disable?
      return true unless Postgres.config?
      return false
    end

    def handle_post_toot(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end

    def handle_post_webhook(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end

    def handle_post_upload(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end

    def handle_post_fav(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end

    def handle_post_boost(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end

    def handle_post_bookmark(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end

    def handle_post_search(body, params = {})
      notify(results.to_h) if results.to_h.present?
    end
  end
end