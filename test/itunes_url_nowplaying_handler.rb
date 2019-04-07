module MulukhiyaTootProxy
  class ItunesURLNowplayingHandlerTest < Test::Unit::TestCase
    def setup
      @handler = Handler.create('itunes_url_nowplaying')
    end

    def test_exec
      @handler.exec({'status' => "#nowplaying https://itunes.apple.com\n"})
      assert_nil(@handler.result)

      @handler.exec({'status' => "#nowplaying https://itunes.apple.com/jp/album/hug%E3%81%A3%E3%81%A8-%E3%83%97%E3%83%AA%E3%82%AD%E3%83%A5%E3%82%A2-%E4%B8%BB%E9%A1%8C%E6%AD%8C%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB-%E9%80%9A%E5%B8%B8%E7%9B%A4-op-we-can-hug%E3%81%A3%E3%81%A8-%E3%83%97%E3%83%AA%E3%82%AD%E3%83%A5%E3%82%A2-ed-hug%E3%81%A3%E3%81%A8/1369123162?i=1369123174\n"})
      assert_equal(@handler.result[:entries], ['https://itunes.apple.com/jp/album/hug%E3%81%A3%E3%81%A8-%E3%83%97%E3%83%AA%E3%82%AD%E3%83%A5%E3%82%A2-%E4%B8%BB%E9%A1%8C%E6%AD%8C%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB-%E9%80%9A%E5%B8%B8%E7%9B%A4-op-we-can-hug%E3%81%A3%E3%81%A8-%E3%83%97%E3%83%AA%E3%82%AD%E3%83%A5%E3%82%A2-ed-hug%E3%81%A3%E3%81%A8/1369123162?i=1369123174'])
    end
  end
end
