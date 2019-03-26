require 'yaml'
require 'json'

module MulukhiyaTootProxy
  class CommandHandler < Handler
    def command_name
      return self.class.to_s.split('::').last.sub(/CommandHandler$/, '').underscore
    end

    def exec(body, headers = {})
      return if body['status'] =~ /^[[:digit:]]+$/
      values = {}
      [:parse_yaml, :parse_json].each do |method|
        next unless values = send(method, body['status'])
        next unless values['command'] == command_name
        break if values.present?
      rescue
        next
      end
      return unless values.present?
      dispatch(values)
      body['visibility'] = 'direct'
      body['status'] = create_status(values)
      increment!
    end

    def create_status(values)
      return YAML.dump(values)
    end

    def parse_yaml(body)
      return YAML.safe_load(body)
    rescue
      return nil
    end

    def parse_json(body)
      return JSON.parse(body)
    rescue
      return nil
    end

    def dispatch(values)
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end
  end
end
