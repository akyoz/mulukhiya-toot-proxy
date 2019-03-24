module MulukhiyaTootProxy
  class TaggingDictionaryTest < Test::Unit::TestCase
    def setup
      @dic = TaggingDictionary.new
    end

    def test_exist?
      @dic.delete
      assert_false(@dic.exist?)
      @dic.refresh
      assert(@dic.exist?)
    end
  end
end