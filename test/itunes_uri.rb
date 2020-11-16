module Mulukhiya
  class ItunesURITest < TestCase
    def test_itunes?
      uri = ItunesURI.parse('https://google.com')
      assert_false(uri.itunes?)

      uri = ItunesURI.parse('https://apple.com')
      assert_false(uri.itunes?)

      uri = ItunesURI.parse('https://itunes.apple.com')
      assert(uri.itunes?)

      uri = ItunesURI.parse('https://music.apple.com')
      assert(uri.itunes?)
    end

    def test_album_id
      uri = ItunesURI.parse('https://music.apple.com')
      assert_nil(uri.album_id)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212?i=1299587213&uo=4')
      assert_equal(uri.album_id, 1_299_587_212)

      uri.album_id = '1299587999'
      assert_equal(uri.album_id, 1_299_587_999)
    end

    def test_track_id
      uri = ItunesURI.parse('https://music.apple.com')
      assert_nil(uri.track_id)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212?i=1299587213&uo=4')
      assert_equal(uri.track_id, 1_299_587_213)

      uri.track_id = '1299587999'
      assert_equal(uri.track_id, 1_299_587_999)
    end

    def test_shortenable?
      uri = ItunesURI.parse('https://music.apple.com/')
      assert_false(uri.shortenable?)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212?i=1299587213&uo=4')
      assert(uri.shortenable?)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?i=1299587213&uo=4')
      assert(uri.shortenable?)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?uo=4')
      assert(uri.shortenable?)
    end

    def test_shorten
      uri = ItunesURI.parse('https://itunes.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212?i=1299587213&uo=4')
      assert_equal(uri.shorten.to_s, 'https://music.apple.com/jp/album/1299587212?i=1299587213&uo=4')

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212?i=1299587213&uo=4')
      assert_equal(uri.shorten.to_s, 'https://music.apple.com/jp/album/1299587212?i=1299587213&uo=4')

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212')
      assert_equal(uri.shorten.to_s, 'https://music.apple.com/jp/album/1299587212')
    end

    def test_album_name
      uri = ItunesURI.parse('https://music.apple.com/')
      assert_nil(uri.album_name)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?i=1299587213&uo=4')
      assert_equal(uri.album_name, '「キラキラ☆プリキュアアラモード」後期主題歌シングルED:シュビドゥビ☆スイーツタイム/挿入歌:勇気が君を待ってる - EP')

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?uo=4')
      assert_equal(uri.album_name, '「キラキラ☆プリキュアアラモード」後期主題歌シングルED:シュビドゥビ☆スイーツタイム/挿入歌:勇気が君を待ってる - EP')
    end

    def test_track_name
      uri = ItunesURI.parse('https://music.apple.com/')
      assert_nil(uri.track_name)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?i=1299587213&uo=4')
      assert_equal(uri.track_name, 'シュビドゥビ☆スイーツタイム')

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?uo=4')
      assert_nil(uri.track_name)
    end

    def test_artists
      uri = ItunesURI.parse('https://music.apple.com/')
      assert_nil(uri.artists)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?i=1299587213&uo=4')
      assert_equal(uri.artists,  ['宮本佳那子'])

      uri = ItunesURI.parse('https://music.apple.com/jp/album/1299587212?uo=4')
      assert_equal(uri.artists, ['宮本佳那子', '駒形友梨'])
    end

    def test_image_uri
      uri = ItunesURI.parse('https://music.apple.com')
      assert_nil(uri.image_uri)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212?i=1299587213&uo=4')
      assert_kind_of(Ginseng::URI, uri.image_uri)

      uri = ItunesURI.parse('https://music.apple.com/jp/album/%E3%82%B7%E3%83%A5%E3%83%92-%E3%83%88-%E3%82%A5%E3%83%92-%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%84%E3%82%BF%E3%82%A4%E3%83%A0/1299587212')
      assert_kind_of(Ginseng::URI, uri.image_uri)
    end
  end
end
