module MulukhiyaTootProxy
  class FavNotificationHandlerTest < HandlerTest
    def setup
      @config = Config.instance
      @handler = Handler.create('fav_notification')
      return if @handler.nil? || @handler.disable?
      @account = Environment.account_class.get(token: @config['/test/token'])
      @toot = @account.recent_toot
    end

    def test_handle_post_boost
      return if @handler.nil? || @handler.disable?

      @handler.clear
      @handler.handle_post_fav('id' => 0)
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_post_fav('id' => @toot.id)
      assert(@handler.result[:entries].first[:status_id].positive?)
      assert_equal(@handler.result[:entries].first[:status_id], @toot.id)
    end
  end
end
