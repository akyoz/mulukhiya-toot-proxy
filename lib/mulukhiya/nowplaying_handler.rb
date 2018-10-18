require 'mulukhiya/handler'
require 'mulukhiya/error/imprement'

module MulukhiyaTootProxy
  class NowplayingHandler < Handler
    def exec(body, headers = {})
      status = []
      updated = false
      body['status'].each_line do |line|
        status.push(line.chomp)
        next if updated
        next unless matches = line.strip.match(/^#nowplaying\s+(.*)$/i)
        keyword = matches[1]
        next unless updatable?(keyword)
        update(keyword, status)
        updated = true
        increment!
      end
      body['status'] = status.join("\n")
      return body
    end

    def updatable?(keyword)
      raise ImprementError, 'updatable?が未定義です。'
    end

    def update(keyword, status)
      raise ImprementError, 'updateが未定義です。'
    end
  end
end