module Mulukhiya
  module AttachmentMethods
    def mediatype
      return type.split('/').first
    end

    def pixel_size
      return nil unless meta
      return nil unless meta[:width]
      return nil unless meta[:height]
      return "#{meta[:width]}x#{meta[:height]}"
    end

    def duration
      return nil unless meta
      return nil unless meta[:duration]
      return meta[:duration].to_f.round(2)
    end

    def meta
      redis = MediaMetadataStorage.new
      redis.push(uri) unless redis[uri]
      return redis[uri]
    rescue => e
      logger.error(error: e, path: uri)
      return nil
    end

    def path
      return File.join(Environment.dir, 'tmp/media/', id.to_s.adler32.to_s)
    end

    def size_str
      ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi', 'Yi'].freeze.each_with_index do |unit, i|
        unitsize = 1024.pow(i)
        return "#{(size.to_f / unitsize).floor.commaize}#{unit}B" if size < unitsize * 1024 * 2
      end
      raise 'Too large'
    end

    def self.included(base)
      base.extend(Methods)
    end

    module Methods
      def query_params
        return {
          limit: config['/feed/media/limit'],
        }
      end
    end
  end
end
