module MulukhiyaTootProxy
  class ImageFormatHandler < MediaConvertHandler
    def convert
      return @source&.convert_type(:jpeg)
    end

    def convertable?
      return false unless @source&.image?
      return false if @source.type == :jpeg
      return false if @source.type == :gif
      return false if @source.alpha?
      return true
    end
  end
end
