module Mulukhiya
  class BookmarkGrowiClippingHandlerTest < TestCase
    def setup
      @handler = Handler.create('bookmark_growi_clipping')
      return unless handler?
      @account = Environment.test_account
      @toot = @account.recent_toot
    end

    def test_handle_post_boost
      return unless handler?
      @handler.clear
      @handler.handle_post_bookmark('id' => @toot.id)
      assert_kind_of(Ginseng::URI, Ginseng::URI.parse(@handler.result[:entries].first[:url]))
    end
  end
end
