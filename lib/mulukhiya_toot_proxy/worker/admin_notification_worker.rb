module MulukhiyaTootProxy
  class AdminNotificationWorker < NotificationWorker
    def perform(params)
      from_account = Account.new(id: params['account_id'])
      @db.execute('notificatable_accounts', {id: from_account.id}).each do |row|
        Account.new(id: row['id']).slack.say(
          create_message(account: from_account, status: params['status']),
          :text,
        )
      rescue Ginseng::ConfigError
        next
      rescue => e
        @logger.error(Ginseng::Error.create(e).to_h.concat(row: row))
        next
      end
    end
  end
end
