module Mulukhiya
  class AmazonURLNowplayingHandlerTest < TestCase
    def setup
      @handler = Handler.create('amazon_url_nowplaying')
    end

    def test_handle_pre_toot
      return unless handler?

      @handler.clear
      @handler.handle_pre_toot(status_field => "#nowplaying https://www.amazon.co.jp/\n")
      assert_nil(@handler.debug_info)

      @handler.clear
      @handler.handle_pre_toot(status_field => "#nowplaying https://www.amazon.co.jp/dp/B00QIUDCXS\n")
      return if @handler.debug_info[:errors].present?
      assert_equal(@handler.debug_info[:result], [{url: 'https://www.amazon.co.jp/dp/B00QIUDCXS'}])
    end
  end
end
