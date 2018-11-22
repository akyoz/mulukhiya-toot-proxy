require 'yaml'
require 'json'

module MulukhiyaTootProxy
  class CommandHandler < Handler
    def command_name
      return self.class.to_s.split('::').last.sub(/CommandHandler$/, '').underscore
    end

    def exec(body, headers = {})
      values = {}
      [:parse_yaml, :parse_json].each do |method|
        next unless values = send(method, body['status'])
        next unless values['command'] == command_name
        body['visibility'] = 'direct'
        body['status'] = YAML.dump(values)
        break
      rescue => e
        Slack.broadcast(Error.create(e).to_h)
        next
      end
      dispatch(values) if values.present?
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
      raise ImprementError, "#{__method__}が未実装です。"
    end
  end
end
