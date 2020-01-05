module MulukhiyaTootProxy
  class DropboxClipperTest < TestCase
    def setup
      @clipper = Environment.test_account.dropbox
    end

    def test_create
      assert_kind_of(DropboxClipper, @clipper)
    end

    def test_clip
      assert_kind_of(DropboxApi::Metadata::File, @clipper.clip("#{Time.now} #{__method__}"))
    end
  end
end