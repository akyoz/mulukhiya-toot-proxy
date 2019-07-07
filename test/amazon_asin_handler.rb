module MulukhiyaTootProxy
  class AmazonASINHandlerTest < Test::Unit::TestCase
    def setup
      @config = Config.instance
      @config['/test/token'] = 'hoge' if Environment.ci?
      @handler = Handler.create('amazon_asin')
    end

    def test_handle_pre_toot
      @config['/amazon/affiliate'] = false
      r = @handler.handle_pre_toot({'status' => 'https://www.amazon.co.jp/日本語の長い長い商品名/dp/B07CJ4KH1T/ref=sr_1_1?s=hobby&ie=UTF8&qid=1529591544&sr=1-1'})
      assert_equal(@handler.result[:entries], ['https://www.amazon.co.jp/日本語の長い長い商品名/dp/B07CJ4KH1T/ref=sr_1_1?s=hobby&ie=UTF8&qid=1529591544&sr=1-1'])
      assert_equal(r['status'], 'https://www.amazon.co.jp/dp/B07CJ4KH1T')

      @config['/amazon/affiliate'] = true
      @config['/amazon/associate_tag'] = 'pooza'
      r = @handler.handle_pre_toot({'status' => 'https://www.amazon.co.jp/日本語の長い長い商品名/dp/B07CJ4KH1T/ref=sr_1_1?s=hobby&ie=UTF8&qid=1529591544&sr=1-1'})
      assert_equal(r['status'], 'https://www.amazon.co.jp/dp/B07CJ4KH1T?tag=pooza')
    end
  end
end
