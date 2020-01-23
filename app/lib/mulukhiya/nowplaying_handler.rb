module Mulukhiya
  class NowplayingHandler < Handler
    def handle_pre_toot(body, params = {})
      @source_status = body[status_field].to_s
      return if create_parser(@source_status).command?
      @source_status.gsub!(/^#(nowplaying)[[:space:]]+(.*)$/i, '#\\1 \\2')
      @status = []
      updated = false
      @source_status.each_line do |line|
        @status.push(line.chomp)
        next if updated
        next unless matches = line.strip.match(/^#nowplaying\s+(.*)$/i)
        keyword = matches[1]
        next unless updatable?(keyword)
        update(keyword)
        updated = true
        @result.push(keyword)
      end
      body[status_field] = @status.join("\n")
      return body
    end

    def updatable?(keyword)
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    alias executable? updatable?

    def update(keyword)
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    private

    def push(line)
      lines = @source_status.each_line.to_a.map(&:chomp)
      @status.push(line) unless lines.include?(line)
    end
  end
end
