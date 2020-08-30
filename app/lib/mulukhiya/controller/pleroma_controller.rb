module Mulukhiya
  class PleromaController < MastodonController
    include ControllerMethods

    post '/api/v1/pleroma/chats/:chat_id/messages' do
      params[status_field] = params[@config['/pleroma/chat/field']]
      Handler.dispatch(:pre_chat, params, {reporter: @reporter, sns: @sns})
      params[@config['/pleroma/chat/field']] = params[status_field]
      @reporter.response = @sns.say(params)
      notify(@reporter.response.parsed_response) if response_error?
      Handler.dispatch(:post_chat, params, {reporter: @reporter, sns: @sns})
      @renderer.message = @reporter.response.parsed_response
      @renderer.status = @reporter.response.code
      return @renderer.to_s
    rescue Ginseng::ValidateError => e
      @renderer.message = {'error' => e.message}
      notify('error' => e.raw_message)
      @renderer.status = e.status
      return @renderer.to_s
    end

    post '/api/v1/media' do
      Handler.dispatch(:pre_upload, params, {reporter: @reporter, sns: @sns})
      @reporter.response = @sns.upload(params[:file][:tempfile].path, {
        filename: params[:file][:filename],
      })
      Handler.dispatch(:post_upload, params, {reporter: @reporter, sns: @sns})
      @renderer.message = JSON.parse(@reporter.response.body)
      @renderer.status = @reporter.response.code
      return @renderer.to_s
    rescue RestClient::Exception => e
      @renderer.message = e.response ? JSON.parse(e.response.body) : e.message
      notify(@renderer.message)
      @renderer.status = e.response&.code || 400
      return @renderer.to_s
    end

    def self.name
      return 'Pleroma'
    end

    def self.webhook_entries
      return enum_for(__method__) unless block_given?
      Pleroma::AccessToken.order(Sequel.desc(:inserted_at)).all do |token|
        yield token.to_h if token.valid?
      end
    end
  end
end
