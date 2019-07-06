module MulukhiyaTootProxy
  class YouTubeURLNowplayingHandlerTest < Test::Unit::TestCase
    def setup
      return if Environment.ci?
      @handler = Handler.create('you_tube_url_nowplaying')
    end

    def test_handle_pre_toot
      return if Environment.ci?

      @handler.clear
      @handler.handle_pre_toot({'status' => "#nowplaying https://www.youtube.com\n"})
      assert_nil(@handler.result)

      @handler.clear
      @handler.handle_pre_toot({'status' => "#nowplaying https://www.youtube.com/watch?v=uFfsTeExwbQ\n"})
      assert_equal(@handler.result[:entries], ['https://www.youtube.com/watch?v=uFfsTeExwbQ'])

      @handler.clear
      @handler.handle_pre_toot({'status' => "#nowplaying \n\nhttps://www.youtube.com/watch?v=uFfsTeExwbQ\n"})
      assert_equal(@handler.result[:entries], ['https://www.youtube.com/watch?v=uFfsTeExwbQ'])
    end
  end
end
