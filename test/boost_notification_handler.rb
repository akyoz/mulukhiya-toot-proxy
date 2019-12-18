module MulukhiyaTootProxy
  class BoostNotificationHandlerTest < TestCase
    def setup
      @config = Config.instance
      @handler = Handler.create('boost_notification')

      return if invalid_handler?
      @account = Environment.account_class.get(token: @config['/test/token'])
      @toot = @account.recent_toot
    end

    def test_handle_post_boost
      return if invalid_handler?

      @handler.clear
      @handler.handle_post_boost('id' => 0)
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_post_boost('id' => @toot.id)
      assert(@handler.result[:entries].first[:status_id].positive?)
      assert_equal(@handler.result[:entries].first[:status_id], @toot.id)
    end
  end
end
