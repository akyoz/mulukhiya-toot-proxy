module Mulukhiya
  module AttachmentMethods
    def mediatype
      return type.split('/').first
    end

    def logger
      @logger ||= Logger.new
      return @logger
    end

    def config
      return Config.instance
    end

    def size_str
      ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi', 'Yi'].freeze.each_with_index do |unit, i|
        unitsize = 1024.pow(i)
        return "#{(size.to_f / unitsize).floor.commaize}#{unit}B" if size < unitsize * 1024 * 2
      end
      raise 'Too large'
    end
  end
end
