module MulukhiyaTootProxy
  class NoteParser < StatusParser
    attr_accessor :dolphin
    attr_accessor :account

    def initialize(body = '')
      super(body)
      @dolphin = DolphinService.new
      @account = Environment.test_account
    end

    def accts
      return body.scan(NoteParser.acct_pattern).map(&:first)
    end

    def to_md
      tmp_body = body.clone
      tags.sort_by(&:length).reverse_each do |tag|
        uri = @dolphin.uri.clone
        uri.path = "/tags/#{tag}"
        tmp_body.gsub!("\##{tag}", "[__HASH__#{tag}](#{uri})")
      end
      accts.sort_by {|v| v.scan(/@/).count * 100_000_000 + v.length}.reverse_each do |acct|
        uri = @dolphin.uri.clone
        uri.path = "/#{acct}"
        tmp_body.sub!(acct, "[#{acct.gsub('@', '__ATMARK__')}](#{uri})")
      end
      tmp_body.gsub!('__HASH__', '#')
      tmp_body.gsub!('__ATMARK__', '@')
      return StatusParser.sanitize(tmp_body)
    end

    def max_length
      length = Config.instance['/dolphin/note/max_length']
      length = length - all_tags.join(' ').length - 1 if all_tags.present?
      return length
    end

    def self.hashtag_pattern
      return Regexp.new(Config.instance['/dolphin/hashtag/pattern'], Regexp::IGNORECASE)
    end

    def self.acct_pattern
      return Regexp.new(Config.instance['/dolphin/acct/pattern'], Regexp::IGNORECASE)
    end
  end
end
