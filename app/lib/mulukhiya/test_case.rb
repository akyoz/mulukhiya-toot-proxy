require 'sidekiq/testing'
require 'rack/test'

module Mulukhiya
  class TestCase < Ginseng::TestCase
    include Package
    include SNSMethods

    def account
      @account ||= account_class.test_account
      return @account
    rescue => e
      logger.error(error: e)
      return nil
    end

    def test_token
      return account_class.test_token
    rescue => e
      logger.error(error: e)
      return nil
    end

    def handler?
      return false if @handler.nil?
      return false if @handler.disable?
      return true
    end

    def self.load
      ENV['TEST'] = Package.full_name
      Sidekiq::Testing.fake!
      names.each do |name|
        puts "case: #{name}"
        require File.join(dir, "#{name}.rb")
      end
    end

    def self.names
      if arg = ARGV.first.split(/[^[:word:],]+/)[1]
        names = []
        arg.split(',').each do |name|
          names.push(name) if File.exist?(File.join(dir, "#{name}.rb"))
          names.push("#{name}_test") if File.exist?(File.join(dir, "#{name}_test.rb"))
        end
      end
      names ||= Dir.glob(File.join(dir, '*.rb')).map {|v| File.basename(v, '.rb')}
      TestCaseFilter.all do |filter|
        next unless filter.active?
        puts "filter: #{filter.class}" if Environment.test?
        filter.exec(names)
      end
      return names.sort.uniq
    end

    def self.dir
      return File.join(Environment.dir, 'test')
    end
  end
end
