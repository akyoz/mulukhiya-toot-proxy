module MulukhiyaTootProxy
  class TaggingHandlerTest < TestCase
    def setup
      @config = Config.instance
      @handler = Handler.create('tagging')
      @config['/tagging/dictionaries'] = [
        {
          'url' => 'https://script.google.com/macros/s/AKfycbwn4nqKhBwH3aDYd7bJ698-GWRJqpktpAdH11ramlBK87ym3ME/exec',
          'type' => 'relative',
        },
        {
          'url' => 'https://script.google.com/macros/s/AKfycbzAUsRUuFLO72EgKta020v9OMtxvUtqUcPZNJ3_IMlOo8dRO7tW/exec',
          'type' => 'relative',
        },
        {
          'url' => 'https://script.google.com/macros/s/AKfycbyy5EQHvhKfm1Lg6Ae4W7knG4BCSkvepJyB6MrzQ8UIxmFfZMJj/exec',
          'type' => 'relative',
        },
        {
          'url' => 'https://script.google.com/macros/s/AKfycbxkcvrTTieJCeGotxlyENQ5vpS1RQnoLFzH3ti5UOHsuTFOfpE/exec',
          'type' => 'relative',
        },
      ]
      @config['/tagging/ignore_addresses'] = ['@pooza']
    end

    def test_handle_pre_toot_without_default_tags
      return unless handler?
      @config['/tagging/default_tags'] = []

      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'hoge'})[message_field]).tags
      assert_equal(tags.count, 0)

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => '宮本佳那子'})[message_field]).tags
      assert_equal(tags.count, 1)
      assert(tags.member?('宮本佳那子'))

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'キュアソードの中の人は宮本佳那子。'})[message_field]).tags
      assert(tags.member?('宮本佳那子'))
      assert(tags.member?('キュアソード'))
      assert(tags.member?('剣崎真琴'))
      assert_equal(tags.count, 3)

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'キュアソードの中の人は宮本 佳那子。'})[message_field]).tags
      assert_equal(tags.count, 3)

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'キュアソードの中の人は宮本　佳那子。'})[message_field]).tags
      assert_equal(tags.count, 3)

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => '#キュアソード の中の人は宮本佳那子。'})[message_field]).tags
      assert_equal(tags.count, 3)

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'Yes!プリキュア5 GoGo!'})[message_field]).tags
      assert_equal(tags.count, 1)
      assert(tags.member?('Yes_プリキュア5GoGo'))

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'Yes!プリキュア5 Yes!プリキュア5 GoGo!'})[message_field]).tags
      assert_equal(tags.count, 2)
      assert(tags.member?('Yes_プリキュア5'))
      assert(tags.member?('Yes_プリキュア5GoGo'))

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => "つよく、やさしく、美しく。\n#キュアフローラ_キュアマーメイド"})[message_field]).tags
      assert_equal(tags.count, 7)
      assert(tags.member?('キュアフローラ_キュアマーメイド'))
      assert(tags.member?('キュアフローラ'))
      assert(tags.member?('春野はるか'))
      assert(tags.member?('嶋村侑'))
      assert(tags.member?('キュアマーメイド'))
      assert(tags.member?('海藤みなみ'))
      assert(tags.member?('浅野真澄'))

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => '#キュアビューティ'})[message_field]).tags
      assert_equal(tags.count, 3)
      assert(tags.member?('キュアビューティ'))
      assert(tags.member?('青木れいか'))
      assert(tags.member?('西村ちなみ'))
    end

    def test_handle_pre_toot_with_direct
      return unless handler?

      @handler.clear
      r = @handler.handle_pre_toot({
        message_field => 'キュアソード',
        'visibility' => 'direct',
      })
      assert_equal(r[message_field], 'キュアソード')
    end

    def test_handle_pre_toot_with_default_tag
      return unless handler?
      @config['/tagging/default_tags'] = ['美食丼']

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => 'hoge'})[message_field]).tags
      assert_equal(tags.count, 1)
      assert(tags.member?('美食丼'))

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => '宮本佳那子'})[message_field]).tags
      assert_equal(tags.count, 2)
      assert(tags.member?('美食丼'))
      assert(tags.member?('宮本佳那子'))

      @handler.clear
      tags = TootParser.new(@handler.handle_pre_toot({message_field => '#美食丼'})[message_field]).tags
      assert_equal(tags.count, 1)
      assert(tags.member?('美食丼'))

      @handler.clear
      r = @handler.handle_pre_toot({message_field => 'プリキュア', 'visibility' => 'private'})
      assert_equal(r[message_field], 'プリキュア')
    end

    def test_handle_pre_toot_with_poll
      return unless handler?
      @config['/tagging/default_tags'] = []

      @handler.clear
      body = {
        message_field => 'アンケート',
        'poll' => {'options' => ['項目1', '項目2', 'ふたりはプリキュア']},
      }
      assert_equal(@handler.handle_pre_toot(body)[message_field], "アンケート\n#ふたりはプリキュア")
    end

    def test_handle_pre_toot_with_twittodon
      return unless handler?
      @config['/tagging/default_tags'] = []

      @handler.clear
      body = {message_field => "みんな〜！「スター☆トゥインクルプリキュア  おほしSUMMERバケーション」が今日もオープンしているよ❣️会場内では、スタンプラリーを開催中！！😍🌈今年のスタンプラリーシートは…なんと！トゥインクルブック型！！🌟フワも登場してとーっても可愛いデザインだよ💖スタンプを全て集めると、「夜空でピカッとステッカー」も貰えちゃう！😍みんなは全部見つけられるかな！？会場内で、ぜひチェックしてね！💫 #スタートゥインクルプリキュア#おほしSUMMERバケーション#スタプリ#池袋プリキュア #フワ#トゥインクルブック#スタンプラリー\n\nvia. https://www.instagram.com/precure_event/p/"}
      assert_equal(@handler.handle_pre_toot(body)[message_field], "みんな〜！「スター☆トゥインクルプリキュア  おほしSUMMERバケーション」が今日もオープンしているよ❣️会場内では、スタンプラリーを開催中！！😍🌈今年のスタンプラリーシートは…なんと！トゥインクルブック型！！🌟フワも登場してとーっても可愛いデザインだよ💖スタンプを全て集めると、「夜空でピカッとステッカー」も貰えちゃう！😍みんなは全部見つけられるかな！？会場内で、ぜひチェックしてね！💫 #スタートゥインクルプリキュア #おほしSUMMERバケーション #スタプリ #池袋プリキュア #フワ #トゥインクルブック #スタンプラリー\n#スター_トゥインクルプリキュア\n\nvia. https://www.instagram.com/precure_event/p/")

      @handler.clear
      body = {message_field => "【新商品】「プリキュアランド第2弾 SPLASH☆WATER」より『アクリルスタンド』『シーズンパスポート』『缶バッジ』が8/25(日)発売だよ！ あっつ～い夏に楽しく元気に水遊びをするみんなを見てたらこちらも涼しくなっちゃう？ それともヒートアップしちゃう？ #プリキュア #プリティストア\n\n(via. Twitter https://twitter.com/pps_as/status/1161472629217218560)"}
      assert_equal(@handler.handle_pre_toot(body)[message_field], "【新商品】「プリキュアランド第2弾 SPLASH☆WATER」より『アクリルスタンド』『シーズンパスポート』『缶バッジ』が8/25(日)発売だよ！ あっつ～い夏に楽しく元気に水遊びをするみんなを見てたらこちらも涼しくなっちゃう？ それともヒートアップしちゃう？ #プリキュア #プリティストア\n\n(via. Twitter https://twitter.com/pps_as/status/1161472629217218560)")
    end

    def test_end_with_tags?
      return unless handler?
      @config['/tagging/default_tags'] = []

      @handler.clear
      last = @handler.handle_pre_toot({message_field => '宮本佳那子'})[message_field].each_line.to_a.last.chomp
      assert_equal(last, '#宮本佳那子')

      @handler.clear
      last = @handler.handle_pre_toot({message_field => "宮本佳那子\n#aaa #bbb"})[message_field].each_line.to_a.last.chomp
      assert_equal(last, '#宮本佳那子 #aaa #bbb')
    end

    def test_ignore_addresses
      return unless handler?
      @config['/tagging/default_tags'] = []

      @handler.clear
      assert_equal(@handler.handle_pre_toot({message_field => '@pooza #キュアビューティ'})[message_field], '@pooza #キュアビューティ')
    end
  end
end
