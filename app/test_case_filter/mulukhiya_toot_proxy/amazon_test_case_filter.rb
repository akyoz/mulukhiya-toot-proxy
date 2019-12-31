module MulukhiyaTootProxy
  class AmazonTestCaseFilter < TestCaseFilter
    def active?
      return !AmazonService.config?
    end
  end
end
