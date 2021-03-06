module Mulukhiya
  class VideoFormatConvertHandler < MediaConvertHandler
    def convert
      return @source.convert_type(type)
    ensure
      result.push(source: {type: @source.type})
    end

    def convertable?
      return false unless @source&.video?
      return false unless type
      return false if @source.type == type
      return true
    end

    def type
      return controller_class.default_video_type
    end

    def media_class
      return VideoFile
    end
  end
end
