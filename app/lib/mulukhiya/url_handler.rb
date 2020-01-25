module Mulukhiya
  class URLHandler < Handler
    def handle_pre_toot(body, params = {})
      @status = body[status_field].to_s
      return if parser.command?
      parser.uris do |uri|
        link = uri.to_s
        next unless rewritable?(link)
        @result.push(source_url: link, rewrited_url: rewrite(link).to_s)
      end
    end

    def rewrite(link)
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def rewritable?(link)
      return true
    end

    alias executable? rewritable?
  end
end
