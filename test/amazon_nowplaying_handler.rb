module MulukhiyaTootProxy
  class AmazonNowplayingHandlerTest < TestCase
    def setup
      @handler = Handler.create('amazon_nowplaying')
    end

    def test_handle_pre_toot
      return if invalid_handler?
      @handler.clear
      @handler.handle_pre_toot({message_field => "#nowplaying #五條真由美 ガンバランス de ダンス\n"})
      assert(@handler.result[:entries].present?)
    end
  end
end
