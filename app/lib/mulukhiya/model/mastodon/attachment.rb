module Mulukhiya
  module Mastodon
    class Attachment < Sequel::Model(:media_attachments)
      many_to_one :status

      def to_h
        @hash ||= values.clone.compact
        return @hash
      end

      alias type file_content_type

      def self.catalog(params = {})
        Postgres.instance.execute('media_catalog', params).each do |row|
          yield ({
            link: create_link(row).to_s,
            title: row[:description] || row[:name],
            author: row[:display_name] || "@#{row[:username]}@#{Environment.domain_name}",
            date: Time.parse("#{row[:created_at]} UTC").getlocal,
          })
        end
      end

      def self.create_link(row)
        path = File.join(
          '/media/media_attachments/files',
          row[:id].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1/'),
          row[:size] || 'original',
          row[:name],
        )
        return Environment.sns_class.new.create_uri(path)
      end
    end
  end
end
