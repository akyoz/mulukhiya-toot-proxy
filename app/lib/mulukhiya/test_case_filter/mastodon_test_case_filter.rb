module Mulukhiya
  class MastodonTestCaseFilter < TestCaseFilter
    def active?
      return !Environment.mastodon?
    end
  end
end
