module MulukhiyaTootProxy
  class GrowiClippingCommandHandler < CommandHandler
    def dispatch(values)
      values['uri'] ||= values['url']
      raise RequestError, 'Empty URL' unless values['uri'].present?
      uri = MastodonURI.parse(values['uri'])
      raise RequestError, "Invalid URL '#{values['uri']}'" unless uri.absolute?
      raise RequestError, 'Invalid toot ID' unless uri.toot_id.present?
      uri.clip({growi: mastodon.growi, path: path})
    end

    def path
      @path ||= '/%{package}/users/%{username}/%{date}' % {
        package: Package.name,
        username: mastodon.account['username'],
        date: Time.now.strftime('%Y/%m/%d/%H%M%S'),
      }
      return @path
    end
  end
end
