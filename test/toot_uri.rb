module Mulukhiya
  class TootURITest < TestCase
    def setup
      @uri = TootURI.parse('https://precure.ml/web/statuses/101118840135913675')
    end

    def test_id
      assert_equal(@uri.id, 101_118_840_135_913_675)
    end

    def test_service
      assert_kind_of(sns_class, @uri.service)
    end

    def test_to_md
      assert_equal(@uri.to_md, "## アカウント\n[ぷーざ@キュアスタ！ :sabacan:](https://precure.ml/@pooza)\n## 本文\n本店わかんなかったけどw とりあえず最寄りの満州で、昼間からビールです。\n## URL\nhttps://precure.ml/web/statuses/101118840135913675\n")
    end
  end
end
