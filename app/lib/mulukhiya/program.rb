module Mulukhiya
  class Program
    include Singleton

    def update
      File.write(path, @http.get(@config['/programs/url']))
      @logger.info(class: self.class.to_s, count: count)
    rescue Ginseng::ConfigError => e
      @logger.error(class: self.class.to_s, error: e.message)
    end

    def path
      return File.join(Environment.dir, 'tmp/cache/programs.json')
    end

    def data
      return JSON.parse(File.read(path))
    end

    def count
      return data.count
    end

    def to_yaml
      return YAML.dump(data)
    end

    alias to_s to_yaml

    private

    def initialize
      @config = Config.instance
      @http = HTTP.new
      @logger = Logger.new
    end
  end
end