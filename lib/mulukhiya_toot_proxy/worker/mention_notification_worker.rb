module MulukhiyaTootProxy
  class MentionNotificationWorker < NotificationWorker
    def perform(params)
      accounts = params['status'].scan(/@([[:word:]]+)(\s|$)/).map {|a| a.first}.uniq
      pattern = "(#{accounts.join('|')})"
      db.execute('notificatable_accounts', {id: params['id'], pattern: pattern}).each do |row|
        next unless slack = connect_slack(row['id'])
        slack.say(create_message({
          account: db.execute('account', {id: params['id']}).first,
          status: params['status'],
        }), :text)
      rescue => e
        Slack.broadcast(Error.create(e).to_h)
        next
      end
    end
  end
end
