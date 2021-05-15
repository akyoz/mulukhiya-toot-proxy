module Mulukhiya
  class MediaMetadataStorageTest < TestCase
    def setup
      @storage = MediaMetadataStorage.new
      @jpeg = File.join(Environment.dir, 'public/mulukhiya/media/logo.jpg')
      @mp4 = File.join(Environment.dir, 'public/mulukhiya/media/poyke.mp4')
      @mp3 = File.join(Environment.dir, 'public/mulukhiya/media/hugttocatch.mp3')
      @uri = Ginseng::URI.parse('https://images-na.ssl-images-amazon.com/images/I/71KPGeyC85L._AC_SL1500_.jpg')
    end

    def test_push
      @storage.push(@jpeg)
      @storage.push(@mp4)
      @storage.push(@mp3)
      @storage.push(@uri)
      assert_equal(@storage[@jpeg], {
        height: 400,
        mediatype: 'image',
        size: 41_440,
        subtype: 'jpeg',
        type: 'image/jpeg',
        width: 400,
      })
      assert_equal(@storage[@mp4], {
        duration: 14.32,
        height: 180,
        mediatype: 'video',
        size: 653_423,
        subtype: 'mp4',
        type: 'video/mp4',
        width: 320,
      })
      assert_equal(@storage[@mp3], {
        duration: 5.041625,
        mediatype: 'audio',
        size: 90_975,
        subtype: 'mpeg',
        type: 'audio/mpeg',
      })
      assert_equal(@storage[@uri], {
        height: 964,
        mediatype: 'image',
        size: 124_728,
        subtype: 'jpeg',
        type: 'image/jpeg',
        width: 1453,
      })
    end
  end
end
