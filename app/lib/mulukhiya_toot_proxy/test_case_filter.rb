module MulukhiyaTootProxy
  class TestCaseFilter
    def active?
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def name
      return @params['/name']
    end

    def params=(values)
      @params = Config.flatten('', values)
    end

    def exec(cases)
      cases.delete_if do |v|
        @params['/cases'].member?(File.basename(v, '.rb'))
      end
    end

    def member?(name)
      return cases.member?(File.basename(name, '.rb'))
    end

    def self.create(name)
      Config.instance['/test/filters'].each do |entry|
        next unless entry['name'] == name
        return "MulukhiyaTootProxy::#{name.camelize}TestCaseFilter".constantize.new(entry)
      end
    end

    def self.all
      Config.instance['/test/filters'].each do |entry|
        yield TestCaseFilter.create(entry['name'])
      end
    end

    private

    def initialize(params)
      self.params = params
    end
  end
end
