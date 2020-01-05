module MulukhiyaTootProxy
  class MessageParserTest < TestCase
    def setup
      @parser = MessageParser.new
    end

    def test_body
      @parser.body = 'ローリン♪ローリン♪ココロにズッキュン'
      assert_equal(@parser.body, 'ローリン♪ローリン♪ココロにズッキュン')
      assert_equal(@parser.to_s, 'ローリン♪ローリン♪ココロにズッキュン')
    end

    def test_length
      @parser.body = 'ローリン♪ローリン♪ココロにズッキュン'
      assert_equal(@parser.length, 19)
    end

    def test_exec
      @parser.body = 'ローリン♪ローリン♪ココロにズッキュン'
      assert_nil(@parser.exec)
      assert_nil(@parser.command_name)
      assert_false(@parser.command?)

      @parser.body = "command: command1\nfoo: bar"
      assert_equal(@parser.exec, {'command' => 'command1', 'foo' => 'bar'})
      assert_equal(@parser.command_name, 'command1')
      assert(@parser.command?)

      @parser.body = '{"command": "command2", "bar": "buz"}'
      assert_equal(@parser.exec, {'command' => 'command2', 'bar' => 'buz'})
      assert_equal(@parser.command_name, 'command2')
      assert(@parser.command?)
    end

    def test_hashtags
      @parser.body = 'pooza@b-shock.org'
      assert_equal(@parser.hashtags, [])

      @parser.body = '#aaa #bbbb @pooza @pooza@precure.ml よろです。'
      assert_equal(@parser.hashtags, ['aaa', 'bbbb'])
    end
  end
end