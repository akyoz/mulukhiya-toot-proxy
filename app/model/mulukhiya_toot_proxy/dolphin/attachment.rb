module MulukhiyaTootProxy
  module Dolphin
    class Attachment < Sequel::Model(:drive_file)
      alias to_h values

      alias file_content_type type
    end
  end
end