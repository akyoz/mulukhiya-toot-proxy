require 'addressable/uri'

module MulukhiyaTootProxy
  class WebhookImageHandler < Handler
    def exec(body, headers = {})
      return unless body['attachments'].is_a?(Array)
      body['media_ids'] ||= []
      return if body['media_ids'].present?
      body['attachments'].each do |f|
        next unless uri = Addressable::URI.parse(f['image_url'])
        next unless uri.absolute?
        body['media_ids'].push(@mastodon.upload_remote_resource(uri))
        @result.push(uri.to_s)
        break
      rescue => e
        @logger.error(e)
        next
      end
    end
  end
end