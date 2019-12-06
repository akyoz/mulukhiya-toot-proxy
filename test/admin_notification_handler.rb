module MulukhiyaTootProxy
  class AdminNotificationHandlerTest < Test::Unit::TestCase
    def setup
      return if Environment.ci?
      @handler = Handler.create('admin_notification')
      @account = Account.get(token: Config.instance['/test/token'])
      @params = {results: ResultContainer.new}
      @params[:results].response = {'id' => @account.id}
    end

    def test_handle_post_toot
      return if Environment.ci?
      return if @handler.disable?

      @handler.clear
      @handler.handle_post_toot({'status' => 'ふつうのトゥート。'}, @params)
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_post_toot({'status' => "周知を含むトゥートのテスト\n#notify"}, @params)
      assert_equal(@handler.result[:entries], [true])
    end
  end
end
