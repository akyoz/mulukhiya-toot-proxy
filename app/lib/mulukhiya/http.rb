module Mulukhiya
  class HTTP < Ginseng::HTTP
    include Package

    def get(uri, options = {})
      cnt ||= 0
      options[:headers] ||= {}
      options[:headers]['User-Agent'] ||= user_agent
      uri = create_uri(uri)
      start = Time.now
      r = HTTParty.get(uri.normalize, options)
      log(method: 'GET', url: uri.to_s, status: r.code, seconds: Time.now - start)
      raise GatewayError, "Bad response #{r.code}" unless r.code < 400
      return r
    rescue => e
      cnt += 1
      @logger.error(error: e, count: cnt)
      raise GatewayError, e.message, e.backtrace unless cnt < (options[:retry] || retry_limit)
      sleep(retry_seconds)
      retry
    end
  end
end
