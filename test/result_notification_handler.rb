module MulukhiyaTootProxy
  class ResultNotificationHandlerTest < Test::Unit::TestCase
    def setup
      @handler = Handler.create('result_notification')
    end

    def test_handle_post_toot
      return unless Postgres.config?

      @handler.clear
      @handler.handle_post_toot({'status' => 'ふつうのトゥート。'})
      assert_nil(@handler.result)
    end
  end
end
