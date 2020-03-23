module Mulukhiya
  class GrowiTestCaseFilter < TestCaseFilter
    def active?
      return Environment.test_account.growi.present?
    rescue Ginseng::ConfigError
      return true
    end
  end
end