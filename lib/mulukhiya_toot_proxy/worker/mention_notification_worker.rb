module MulukhiyaTootProxy
  class MentionNotificationWorker < NotificationWorker
    def perform(params)
      from_account = Account.new(id: params['account_id'])
      accounts = params['status'].scan(/@([[:word:]]+)(\s|$)/).map(&:first).uniq
      pattern = "(#{accounts.join('|')})"
      @db.execute('notificatable_accounts', {id: from_account.id, pattern: pattern}).each do |row|
        account = Account.new(id: row['id'])
        next unless account.config['/slack/webhook'].present?
        account.slack.say(create_message(account: from_account, status: params['status']), :text)
      rescue => e
        @logger.error(Ginseng::Error.create(e).to_h.merge(row: row))
        next
      end
    end
  end
end
