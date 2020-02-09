module Mulukhiya
  class GrowiBookmarkHandlerTest < TestCase
    def setup
      @handler = Handler.create('growi_bookmark')
      return unless handler?
      @status = Environment.test_account.recent_status
    end

    def test_handle_post_bookmark
      return unless handler?
      @handler.handle_post_bookmark(status_key => @status.id)
      assert_kind_of(Ginseng::URI, Ginseng::URI.parse(@handler.result[:entries].first[:url]))
    end
  end
end