require 'digest/sha1'
require 'mimemagic'
require 'rack/mime'

module Mulukhiya
  class MediaFile < File
    def initialize(path, mode = 'r', perm = 0o600)
      @logger = Logger.new
      super
    end

    def valid?
      return mediatype == default_mediatype
    end

    def mediatype
      return mimemagic&.mediatype
    end

    def default_mediatype
      return self.class.to_s.split('::').last.underscore.split('_').first
    end

    def subtype
      return mimemagic&.subtype
    end

    def type
      return mimemagic&.to_s
    end

    def extname
      return File.extname(path)
    end

    def valid_extname
      @types ||= Rack::Mime::MIME_TYPES.invert
      return @types[type]
    end

    def valid_extname?
      return true if valid_extname.nil?
      return extname == valid_extname
    end

    def width
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def height
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def duration
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def aspect
      return width.to_f / height
    rescue
      return nil
    end

    def long_side
      return [width, height].max
    rescue
      return nil
    end

    def convert_format(type)
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    alias convert_type convert_format

    def create_dest_path(params = {})
      params[:type] ||= default_mediatype
      params[:content] = Digest::SHA1.hexdigest(File.read(path))
      return File.join(
        Environment.dir,
        'tmp/media',
        "#{Digest::SHA1.hexdigest(params.to_json)}.#{params[:type]}",
      )
    end

    def mimemagic
      @mimemagic ||= MimeMagic.by_magic(self)
      return @mimemagic
    end

    def streams
      unless @streams
        command = CommandLine.new([
          'ffprobe', '-v', 'quiet',
          '-print_format', 'json',
          '-show_streams',
          path
        ])
        command.exec
        @streams = JSON.parse(command.stdout)['streams']
      end
      return @streams
    end

    def video_stream
      return streams.find {|v| v['codec_type'] == 'video'}
    end

    def audio_stream
      return streams.find {|v| v['codec_type'] == 'audio'}
    end
  end
end
