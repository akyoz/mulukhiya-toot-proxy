require 'addressable/uri'
require 'nokogiri'

module MulukhiyaTootProxy
  class ItunesURI < Addressable::URI
    def initialize(options = {})
      super(options)
      @config = Config.instance
      @service = ItunesService.new
      @http = HTTP.new
    end

    def itunes?
      return absolute? && host == 'itunes.apple.com'
    end

    alias valid? itunes?

    def shortenable?
      return false unless itunes?
      return false unless album_id.present?
      return false unless track_id.present?
      @config['/itunes/patterns'].each do |entry|
        next unless path.match(Regexp.new(entry['pattern']))
        return entry['shortenable']
      end
      return false
    end

    def shorten
      return self unless shortenable?
      dest = clone
      dest.album_id = album_id
      query_values = {}
      dest.track_id = track_id
      dest.fragment = nil
      return dest
    end

    def album_id
      @config['/itunes/patterns'].each do |entry|
        if matches = path.match(Regexp.new(entry['pattern']))
          return matches[1]
        end
      end
      return nil
    end

    def album_id=(id)
      self.path = "/#{@config['/itunes/country']}//album/#{id}"
    end

    def track_id
      return query_values['i']
    rescue NoMethodError
      return nil
    end

    def track_id=(id)
      query_values ||= {}
      query_values['i'] = id
    end

    alias id track_id

    def track
      return nil unless itunes?
      return nil unless track_id.present?
      return @service.lookup(track_id)
    end

    def image_uri
      return nil unless itunes?
      return nil unless track_id.present?
      track = @service.lookup(track_id)
      raise Ginseng::RequestError, "Track '#{track_id}' not found" unless track
      unless @image_uri
        response = @http.get(track['trackViewUrl'])
        body = Nokogiri::HTML.parse(response.body, nil, 'utf-8')
        elements = body.xpath('//picture/source')
        return nil unless elements.present?
        elements.first.attribute('srcset').text.split(/,/).each do |uri|
          next unless matches = uri.match(/^(.*) +3x$/)
          @image_uri = Addressable::URI.parse(matches[1])
          break if @image_uri&.absolute?
        end
      end
      return @image_uri
    end

    alias image_url image_uri
  end
end
