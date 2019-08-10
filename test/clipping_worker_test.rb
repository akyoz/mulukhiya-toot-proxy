module MulukhiyaTootProxy
  class ClippingWorkerTest < Test::Unit::TestCase
    def setup
      @worker = ClippingWorker.new
    end

    def test_create_body
      return if Environment.ci?
      body = @worker.create_body('uri' => {
        'class' => 'MulukhiyaTootProxy::MastodonURI',
        'href' => 'https://st.curesta.b-shock.org/web/statuses/102582870209671676',
      })
      assert_equal(body, %{## アカウント\n[@お知らせBOT](https://st.curesta.b-shock.org/@info)\n\n## 本文\n【新着お知らせ】  06/08 インスタンスについて\nhttps://growi.b-shock.org/user/pooza/st.curesta/2019/06/08/%E3%82%A4%E3%83%B3%E3%82%B9%E3%82%BF%E3%83%B3%E3%82%B9%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6  06/08 お知らせBOT\nhttps://growi.b-shock.org/user/pooza/st.curesta/2019/06/08/%E3%81%8A%E7%9F%A5%E3%82%89%E3%81%9BBOT\n#stg_precure_fun\n\n## URL\nhttps://st.curesta.b-shock.org/@info/102582870209671676\n})
    end
  end
end
