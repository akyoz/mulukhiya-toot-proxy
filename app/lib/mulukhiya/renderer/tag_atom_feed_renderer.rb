require 'digest/sha1'

module Mulukhiya
  class TagAtomFeedRenderer < AtomFeedRenderer
    include Package

    attr_reader :logger, :tag, :limit

    def initialize(channel = {})
      super
      @sns = Environment.sns_class.new
      channel.merge!(
        title: "##{tag} | #{@sns.info['title']}",
        link: @sns.create_uri("/tags/#{tag}").to_s,
        description: "#{@sns.info['title']} ##{tag}のタイムライン",
      )
      @limit = @config['/feed/tag/limit']
    end

    def tag=(tag)
      @tag = tag
      @atom = nil
    end

    def limit=(limit)
      @limit = limit
      @atom = nil
    end

    def params
      return {tag: tag, limit: limit}
    end

    def cache!
      File.write(path, fetch)
      @logger.info(action: 'cached', params: params)
    end

    def path
      return File.join(
        Environment.dir,
        'tmp/cache/',
        "#{Digest::SHA1.hexdigest(params.to_json)}.atom",
      )
    end

    def exist?
      return File.exist?(path)
    end

    def self.cache_all
      all do |renderer|
        renderer.cache!
      rescue => e
        renderer.logger.error(Ginseng::Error.create(e).to_h.merge(tag: tag))
      end
    end

    def to_s
      return nil unless exist?
      return File.read(path)
    end

    def self.all
      return enum_for(__method__) unless block_given?
      tags do |tag|
        renderer = TagAtomFeedRenderer.new
        renderer.tag = tag
        yield renderer
      end
    end

    def self.tags
      return enum_for(__method__) unless block_given?
      TagContainer.new.default_tags.each do |tag|
        yield tag.sub(/^#/, '')
      end
    end

    private

    def fetch
      return unless Postgres.config?
      Postgres.instance.execute('tag_feed', params).each do |row|
        push(
          link: create_link(row[:uri]).to_s,
          title: create_title(row),
          date: Time.parse("#{row[:created_at]} UTC").getlocal,
        )
      end
      @atom = nil
      return atom
    end

    def create_title(row)
      template = Template.new('feed_entry')
      template[:row] = row
      return template.to_s.chomp.sanitize
    end

    def create_link(src)
      dest = Ginseng::URI.parse(src)
      return src unless dest.absolute?
      return src unless matches = %r{/users/([[:word:]]+)/statuses/([[:digit:]]+)}i.match(dest.path)
      dest.path = "/@#{matches[1]}/#{matches[2]}"
      return dest.to_s
    end
  end
end
