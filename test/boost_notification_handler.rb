module MulukhiyaTootProxy
  class BoostNotificationHandlerTest < Test::Unit::TestCase
    def setup
      return if Environment.ci?
      @config = Config.instance
      @handler = Handler.create('boost_notification')
      @account = Account.new(token: @config['/test/token'])
      @toot = @account.recent_toot
    end

    def test_handle_post_boost
      return if Environment.ci?
      return if @handler.disable?

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
