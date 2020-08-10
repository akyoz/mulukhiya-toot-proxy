require 'rack/test'

module Mulukhiya
  class WebhookControllerTest < TestCase
    include ::Rack::Test::Methods

    def setup
      @parser = Environment.parser_class.new
      @parser.account = Environment.test_account
    end

    def app
      return WebhookController
    end

    def test_hook_toot
      header 'Content-Type', 'application/json'
      post '/mulukhiya/webhook', {text: 'ひらめけ！ホーリーソード！'}.to_json
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 404)

      header 'Content-Type', 'application/json'
      post '/mulukhiya/webhook/0', {text: 'ひらめけ！ホーリーソード！'}.to_json
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 404)

      return unless hook = @parser.account.webhook

      get hook.uri.path
      assert(last_response.ok?)

      header 'Content-Type', 'application/json'
      post hook.uri.path, {text: 'ひらめけ！ホーリーソード！'}.to_json
      assert(last_response.ok?)

      header 'Content-Type', 'application/json'
      post hook.uri.path, {text: '武田信玄', attachments: [{image_url: 'https://images-na.ssl-images-amazon.com/images/I/519zZO6YAVL.jpg'}]}.to_json
      assert(last_response.ok?)

      header 'Content-Type', 'application/json'
      post hook.uri.path, {}.to_json
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 422)
    end
  end
end
