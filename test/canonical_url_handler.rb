module Mulukhiya
  class CanonicalURLHandlerTest < TestCase
    def setup
      @handler = Handler.create('canonical_url')
    end

    def test_handle_pre_toot
      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://www.google.co.jp/?q=日本語')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://4sq.com/2NYeZb6')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://www.youtube.com/watch?v=Lvinns9DJs0&feature=youtu.be&t=2252')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'http://www.apple.com')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'http://www.apple.com/')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://stats.uptimerobot.com/QOoGgF2Ak')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://itunes.apple.com/jp/album/1369123162?i=1369123174')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://www.amazon.co.jp/dp/B00QIUDCXS')
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot(status_field => 'https://www.apple.com/jp/apple-music/')
      assert_equal(@handler.result[:entries].first[:rewrited_url], 'https://www.apple.com/jp/apple-music/')
    end
  end
end
