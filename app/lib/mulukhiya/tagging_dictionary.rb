module Mulukhiya
  class TaggingDictionary < Hash
    def initialize
      super
      @config = Config.instance
      @logger = Logger.new
      @http = HTTP.new
      refresh unless exist?
      refresh if corrupted?
      load
    end

    def matches(body)
      r = []
      text = create_temp_text(body)
      reverse_each do |k, v|
        next if k.length < @config['/tagging/word/minimum_length']
        next unless text.match?(v[:pattern])
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
        @logger.error(error: e, k: k, v: v)
      end
      update(sort_by {|k, v| k.length}.to_h)
    end

    def exist?
      return File.exist?(path)
    end

    def corrupted?
      return false unless load_cache.is_a?(Array)
      return true
    rescue TypeError, Errno::ENOENT => e
      @logger.error(error: e, path: path)
      return true
    end

    def path
      return File.join(Environment.dir, 'tmp/cache/tagging_dictionary')
    end

    def load
      return unless exist?
      clear
      update(load_cache)
    end

    def load_cache
      @cache ||= Marshal.load(File.read(path)) # rubocop:disable Security/MarshalLoad
      return @cache
    end

    def refresh
      save_cache
      @logger.info(class: self.class.to_s, path: path, message: 'refreshed')
      load
    rescue => e
      @logger.error(error: e)
    end

    alias create refresh

    def delete
      File.unlink(path) if exist?
    end

    def remote_dics(&block)
      return enum_for(__method__) unless block
      RemoteDictionary.all(&block)
    end

    private

    def fetch
      result = {}
      bar = ProgressBar.create(total: remote_dics.count) if Environment.rake?
      remote_dics do |dic|
        bar&.increment
        dic.parse.each do |k, v|
          result[k] ||= v
          next unless v[:words].is_a?(Array)
          result[k][:words].concat(v[:words]).uniq!
        end
      end
      bar&.finish
      return result.sort_by {|k, v| k.length}.to_h
    end

    def create_temp_text(body)
      status = body[Environment.controller_class.status_field].clone
      status.gsub!(Acct.pattern, '')
      parts = [status]
      options = body.dig('poll', Environment.controller_class.poll_options_field)
      parts.concat(options) if options.present?
      return parts.join('::::')
    end

    def save_cache
      File.write(path, Marshal.dump(fetch))
      @cache = nil
    end
  end
end
