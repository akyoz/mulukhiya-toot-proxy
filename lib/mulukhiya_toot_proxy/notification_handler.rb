module MulukhiyaTootProxy
  class NotificationHandler < Handler
    def notifiable?(body)
      return false
    end

    alias executable? notifiable?

    def worker_class
      return self.class.to_s.sub(/Handler$/, 'Worker').constantize
    end

    def events
      return [:post_toot, :post_webhook]
    end
  end
end
