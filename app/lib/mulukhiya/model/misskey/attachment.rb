module Mulukhiya
  module Misskey
    class Attachment < Sequel::Model(:drive_file)
      alias to_h values

      alias file_content_type type

      def uri
        @uri ||= Ginseng::URI.parse(url)
        return @uri
      end
    end
  end
end
