module MulukhiyaTootProxy
  class AmazonImageHandlerTest < Test::Unit::TestCase
    def setup
      @handler = Handler.create('amazon_image')
    end

    def test_exec
      @handler.clear
      @handler.exec({'status' => 'https://www.amazon.co.jp/gp/customer-reviews/R2W0VIBA0RBSLY/ref=cm_cr_dp_d_rvw_ttl?ie=UTF8&ASIN=B00TYVQBEU'})
      assert_nil(@handler.result)

      @handler.clear
      @handler.exec({'status' => 'Amazon.co.jp | HUGっと!プリキュア オシマイダー Tシャツ ブラック XLサイズ | ホビー 通販 https://www.amazon.co.jp/dp/B07DB67ZR8'})
      assert(@handler.result[:entries].present?)

      @handler.clear
      @handler.exec({'status' => 'https://www.amazon.co.jp/gp/product/B07H2B56RT?pf_rd_p=7b903293-68b0-4a33-9b7c-65c76866a371&pf_rd_r=732H9VVYDF2TD3WYVBKK'})
      assert(@handler.result[:entries].present?)
    end
  end
end
