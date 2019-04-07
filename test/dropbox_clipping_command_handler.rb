module MulukhiyaTootProxy
  class DropboxClippingCommandHandlerTest < Test::Unit::TestCase
    def setup
      config = Config.instance
      @handler = Handler.create('dropbox_clipping_command')
      @handler.mastodon = Mastodon.new(config['/instance_url'], config['/test/token'])
    end

    def test_exec
      @handler.exec({'status' => ''})
      assert_nil(@handler.result)
      sleep(1)

      @handler.exec({'status' => "command: dropbox_clipping\nurl: https://mstdn.b-shock.org/web/statuses/101125535795976504"})
      assert_equal(@handler.result[:entries].count, 1)
      sleep(1)

      @handler.exec({'status' => "command: dropbox_clipping\nurl: https://precure.ml/@pooza/101276312982799462"})
      assert_equal(@handler.result[:entries].count, 2)
      sleep(1)
    end
  end
end
