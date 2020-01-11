module MulukhiyaTootProxy
  class TaggingHandlerTest < TestCase
    def setup
      @handler = Handler.create('tagging')
      @config = Config.instance
      @config['/agent/accts'] = ['@pooza']
    end

    def test_handle_pre_toot
      return unless handler?

      @handler.clear
      tags = Environment.parser_class.new(@handler.handle_pre_toot({status_field => '宮本佳那子'})[status_field]).all_tags
      assert(tags.member?('#宮本佳那子'))

      @handler.clear
      tags = Environment.parser_class.new(@handler.handle_pre_toot({status_field => 'キュアソードの中の人は宮本佳那子。'})[status_field]).all_tags
      assert(tags.member?('#宮本佳那子'))
      assert(tags.member?('#キュアソード'))
      assert(tags.member?('#剣崎真琴'))

      @handler.clear
      tags = Environment.parser_class.new(@handler.handle_pre_toot({status_field => 'Yes!プリキュア5 GoGo!'})[status_field]).all_tags
      assert(tags.member?('#Yes_プリキュア5GoGo'))

      @handler.clear
      tags = Environment.parser_class.new(@handler.handle_pre_toot({status_field => 'Yes!プリキュア5 Yes!プリキュア5 GoGo!'})[status_field]).all_tags
      assert(tags.member?('#Yes_プリキュア5'))
      assert(tags.member?('#Yes_プリキュア5GoGo'))

      @handler.clear
      tags = Environment.parser_class.new(@handler.handle_pre_toot({status_field => "つよく、やさしく、美しく。\n#キュアフローラ_キュアマーメイド"})[status_field]).all_tags
      assert(tags.member?('#キュアフローラ_キュアマーメイド'))
      assert(tags.member?('#キュアフローラ'))
      assert(tags.member?('#春野はるか'))
      assert(tags.member?('#嶋村侑'))
      assert(tags.member?('#キュアマーメイド'))
      assert(tags.member?('#海藤みなみ'))
      assert(tags.member?('#浅野真澄'))

      @handler.clear
      tags = Environment.parser_class.new(@handler.handle_pre_toot({status_field => '#キュアビューティ'})[status_field]).all_tags
      assert(tags.member?('#キュアビューティ'))
      assert(tags.member?('#青木れいか'))
      assert(tags.member?('#西村ちなみ'))
    end

    def test_handle_pre_toot_with_direct
      return unless handler?

      @handler.clear
      r = @handler.handle_pre_toot({status_field => 'キュアソード', 'visibility' => 'direct'})
      assert_equal(r[status_field], 'キュアソード')
    end

    def test_handle_pre_toot_with_poll
      return unless handler?

      @handler.clear
      body = {
        status_field => 'アンケート',
        'poll' => {'options' => ['項目1', '項目2', 'ふたりはプリキュア']},
      }
      assert(@handler.handle_pre_toot(body)[status_field].start_with?("アンケート\n#ふたりはプリキュア"))
    end

    def test_handle_pre_toot_with_twittodon
      return unless handler?
      @config['/tagging/default_tags'] = []

      @handler.clear
      body = {status_field => "みんな〜！「スター☆トゥインクルプリキュア  おほしSUMMERバケーション」が今日もオープンしているよ❣️会場内では、スタンプラリーを開催中！！😍🌈今年のスタンプラリーシートは…なんと！トゥインクルブック型！！🌟フワも登場してとーっても可愛いデザインだよ💖スタンプを全て集めると、「夜空でピカッとステッカー」も貰えちゃう！😍みんなは全部見つけられるかな！？会場内で、ぜひチェックしてね！💫 #スタートゥインクルプリキュア#おほしSUMMERバケーション#スタプリ#池袋プリキュア #フワ#トゥインクルブック#スタンプラリー\n\nvia. https://www.instagram.com/precure_event/p/"}
      lines = @handler.handle_pre_toot(body)[status_field].split("\n")
      assert_equal(lines.last, 'via. https://www.instagram.com/precure_event/p/')

      @handler.clear
      body = {status_field => "【新商品】「プリキュアランド第2弾 SPLASH☆WATER」より『アクリルスタンド』『シーズンパスポート』『缶バッジ』が8/25(日)発売だよ！ あっつ～い夏に楽しく元気に水遊びをするみんなを見てたらこちらも涼しくなっちゃう？ それともヒートアップしちゃう？ #プリキュア #プリティストア\n\n(via. Twitter https://twitter.com/pps_as/status/1161472629217218560)"}
      lines = @handler.handle_pre_toot(body)[status_field].split("\n")
      assert_equal(lines.last, '(via. Twitter https://twitter.com/pps_as/status/1161472629217218560)')
    end

    def test_ignore_accts
      return unless handler?

      @handler.clear
      assert(@handler.handle_pre_toot({status_field => '@pooza #キュアビューティ'})[status_field].start_with?('@pooza #キュアビューティ'))
    end
  end
end
