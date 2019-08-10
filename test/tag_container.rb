module MulukhiyaTootProxy
  class TagContainerTest < Test::Unit::TestCase
    def setup
      @config = Config.instance
      @container = TagContainer.new
    end

    def test_create_tags
      @container.concat(['カレー担々麺', 'コスモグミ'])
      assert_equal(@container.create_tags, ['#カレー担々麺', '#コスモグミ'])

      @container.push('剣崎 真琴')
      @container.push('Makoto Kenzaki')
      assert_equal(@container.create_tags, ['#カレー担々麺', '#コスモグミ', '#剣崎真琴', '#Makoto_Kenzaki'])
    end

    def test_default_tags
      @config['/tagging/default_tags'] = []
      assert_equal(TagContainer.default_tags, [])
      @config['/tagging/default_tags'] = ['美食丼', 'b-shock-don']
      assert_equal(TagContainer.default_tags, ['#美食丼', '#b_shock_don'])
    end

    def test_tweak
      text = "http://www.toei-anim.co.jp/ptr/precure/deco/#m20190809\n\nこれひめは何を持ってるの？\n\nあと一番左の人はなんでちびまるこちゃんのうじきくんみたいな唇なの？#a#b#c"
      assert_equal(TagContainer.tweak(text), "http://www.toei-anim.co.jp/ptr/precure/deco/#m20190809\n\nこれひめは何を持ってるの？\n\nあと一番左の人はなんでちびまるこちゃんのうじきくんみたいな唇なの？ #a #b #c")
    end
  end
end
