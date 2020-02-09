require 'test/unit'
require 'sidekiq/testing'

module Mulukhiya
  class TestCase < Test::Unit::TestCase
    def status_field
      return Environment.controller_class.status_field
    end

    def status_key
      return Environment.controller_class.status_key
    end

    def handler?
      return false if @handler.nil?
      return false if @handler.disable?
      return true
    end

    def self.load
      ENV['TEST'] = Package.name
      Sidekiq::Testing.fake!
      cases = Dir.glob(File.join(Environment.dir, 'test/*.rb'))
      TestCaseFilter.all do |filter|
        filter.exec(cases) if filter.active?
      end
      cases.sort.each do |f|
        puts "case: #{File.basename(f)}"
        require f
      end
    end
  end
end