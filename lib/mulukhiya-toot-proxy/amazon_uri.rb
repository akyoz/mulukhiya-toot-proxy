require 'addressable/uri'

module MulukhiyaTootProxy
  class AmazonURI < Addressable::URI
    def shortenable?
      return amazon? && asin.present?
    end

    def amazon?
      return host.split('.').member?('amazon')
    end

    def asin
      if matches = path.match(%r{/dp/([A-Za-z0-9]+)})
        return matches[1]
      end
      return nil
    end

    def shorten
      return self unless shortenable?
      dest = clone
      dest.path = "/dp/#{asin}"
      dest.query = nil
      dest.fragment = nil
      return dest
    end
  end
end