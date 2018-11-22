require 'crowi-client'

module MulukhiyaTootProxy
  class Growi < CrowiClient
    def push(body)
      request(CPApiRequestPagesCreate.new(body))
    end

    def self.create(params)
      values = UserConfigStorage.new[params[:account_id]]
      return Growi.new({
        crowi_url: values['growi']['url'],
        access_token: values['growi']['token'],
      })
    rescue => e
      Slack.broadcast(Error.create(e).to_h)
      raise ExternalServiceError, 'Growiの接続情報が取得できませんでした。'
    end
  end
end