module Mulukhiya
  class SNSServiceTest < TestCase
    def setup
      @sns = sns_class.new
    end

    def test_info
      assert_kind_of(Hash, @sns.info)
      assert_kind_of(String, @sns.info.dig('metadata', 'maintainer', 'name'))
      assert_kind_of(String, @sns.info.dig('metadata', 'nodeName'))
    end

    def test_account
      assert_kind_of(account_class, @sns.account)
    end

    def test_access_token
      assert_kind_of(access_token_class, @sns.access_token)
    end
  end
end