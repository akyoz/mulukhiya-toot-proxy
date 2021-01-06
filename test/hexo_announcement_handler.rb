module Mulukhiya
  class HexoAnnouncementHandlerTest < TestCase
    def setup
      @handler = Handler.create('hexo_announcement')
      config['/agent/info/token'] = test_token
    end

    def test_handle_announce
      return unless handler?

      @handler.clear
      @handler.handle_announce({text: 'お知らせです。Hexo'}, {sns: info_agent_service})
      assert(File.exist?(@handler.debug_info[:result].first[:path]))
    end
  end
end
