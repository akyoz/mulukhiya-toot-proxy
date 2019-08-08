require 'fastimage'

module MulukhiyaTootProxy
  class ImageFile < MediaFile
    alias image? valid?

    def width
      return size_info[:width]
    end

    def height
      return size_info[:height]
    end

    def duration
      return nil
    end

    def alpha?
      return image? && (detail_info =~ /  alpha:/i).present?
    end

    def resize(pixel)
      dest = create_dest_path(f: __method__, type: subtype)
      command = ['convert', '-resize', "#{pixel}x#{pixel}", path, dest]
      system(*command, {exception: true, out: '/dev/null'}) unless File.exist?(dest)
      return ImageFile.new(dest)
    end

    def convert_type(type)
      dest = create_dest_path(f: __method__, type: type)
      command = ['convert', path, dest]
      system(*command, {exception: true, out: '/dev/null'}) unless File.exist?(dest)
      return ImageFile.new(dest)
    end

    def detail_info
      @detail_info ||= `identify -verbose #{path.shellescape}`
      return @detail_info
    end

    def size_info
      return nil unless image?
      unless @size_info
        size = FastImage.size(path)
        @size_info = {width: size[0], height: size[1]}
      end
      return @size_info
    end
  end
end