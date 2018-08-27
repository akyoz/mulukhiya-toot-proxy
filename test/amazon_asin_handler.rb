require 'mulukhiya/handler/amazon_asin'
require 'mulukhiya/config'

module MulukhiyaTootProxy
  class AmazonAsinHandlerTest < Test::Unit::TestCase
    def test_exec
      handler = AmazonAsinHandler.new
      config = Config.instance

      if config['local']['amazon']['affiliate'] && config.associate_tag
        assert_equal(handler.exec({'status' => 'https://www.amazon.co.jp/日本語の長い長い商品名/dp/B07CJ4KH1T/ref=sr_1_1?s=hobby&ie=UTF8&qid=1529591544&sr=1-1'})['status'], "https://www.amazon.co.jp/dp/B07CJ4KH1T?tag=#{config.associate_tag}")
        assert_equal(handler.result, 'AmazonAsinHandler,1')

        assert_equal(handler.exec({'status' => 'https://www.amazon.co.jp/商品名/dp/hoge https://www.amazon.co.jp/商品名/dp/gebo'})['status'], "https://www.amazon.co.jp/dp/hoge?tag=#{config.associate_tag} https://www.amazon.co.jp/dp/gebo?tag=#{config.associate_tag}")
        assert_equal(handler.result, 'AmazonAsinHandler,3')
      else
        assert_equal(handler.exec({'status' => 'https://www.amazon.co.jp/日本語の長い長い商品名/dp/B07CJ4KH1T/ref=sr_1_1?s=hobby&ie=UTF8&qid=1529591544&sr=1-1'})['status'], 'https://www.amazon.co.jp/dp/B07CJ4KH1T')
        assert_equal(handler.result, 'AmazonAsinHandler,1')

        assert_equal(handler.exec({'status' => 'https://www.amazon.co.jp/商品名/dp/hoge https://www.amazon.co.jp/商品名/dp/gebo'})['status'], 'https://www.amazon.co.jp/dp/hoge https://www.amazon.co.jp/dp/gebo')
        assert_equal(handler.result, 'AmazonAsinHandler,3')
      end
    end
  end
end
