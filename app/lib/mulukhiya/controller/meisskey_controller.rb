module Mulukhiya
  class MeisskeyController < MisskeyController
    def self.webhook_entries
      return enum_for(__method__) unless block_given?
      Meisskey::AccessToken.all.reverse_each do |token|
        yield token.to_h if token.valid?
      end
    end
  end
end
