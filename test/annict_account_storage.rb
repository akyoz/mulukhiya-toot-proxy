module Mulukhiya
  class AnnictAccountStorageTest < TestCase
    def test_accounts
      AnnictAccountStorage.accounts do |account|
        assert_kind_of(account_class, account)
      end
    end
  end
end
