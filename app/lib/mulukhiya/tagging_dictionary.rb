module Mulukhiya
  class TaggingDictionary < Hash
    attr_accessor :text

    def initialize
      super
      @config = Config.instance
      @logger = Logger.new
      @http = HTTP.new
      refresh unless exist?
      refresh if corrupted?
      load
    end

    def matches
      r = []
      reverse_each do |k, v|
        next if k.length < @config['/tagging/word/minimum_length']
        next unless @text.match?(v[:pattern])
        r.push(k)
        r.concat(v[:words])
        text.gsub!(v[:pattern], '')
      end
      return r.uniq
    end

    def concat(values)
      values.each do |k, v|
        self[k] ||= v
        self[k][:words] ||= []
        self[k][:words].concat(v[:words]) if v[:words].is_a?(Array)
      rescue => e
        @logger.error(Ginseng::Error.create(e).to_h.merge(k: k, v: v))
      end
      update(sort_by {|k, v| k.length}.to_h)
    end

    def exist?
      return File.exist?(path)
    end

    def corrupted?
      return false unless Marshal.load(File.read(path)).is_a?(Array) # rubocop:disable Security/MarshalLoad
      return true
    rescue TypeError, Errno::ENOENT => e
      @logger.error(class: self.class.to_s, path: path, message: e.message)
      return true
    end

    def path
      return File.join(Environment.dir, 'tmp/cache/tagging_dictionary')
    end

    def load
      return unless exist?
      clear
      update(Marshal.load(File.read(path))) # rubocop:disable Security/MarshalLoad
    end

    def refresh
      File.write(path, Marshal.dump(fetch))
      @logger.info(class: self.class.to_s, path: path, message: 'refreshed')
      load
    rescue => e
      @logger.error(e)
    end

    alias create refresh

    def delete
      File.unlink(path) if exist?
    end

    def resources
      return enum_for(__method__) unless block_given?
      TaggingResource.all do |r|
        yield r
      end
    end

    def fetch
      result = {}
      resources do |resource|
        resource.parse.each do |k, v|
          result[k] ||= v
          result[k][:words] ||= []
          result[k][:words].concat(v[:words]) if v[:words].is_a?(Array)
        rescue => e
          msg = Ginseng::Error.create(e).to_h.merge(
            resource: {uri: resource.uri.to_s},
            entry: {k: k, v: v},
          )
          @logger.error(msg)
        end
      rescue => e
        @logger.error(Ginseng::Error.create(e).to_h.merge(resource: resource.uri.to_s))
      end
      return result.sort_by {|k, v| k.length}.to_h
    end
  end
end
