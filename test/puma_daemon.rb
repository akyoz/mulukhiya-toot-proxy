module Mulukhiya
  class PumaDaemonTest < TestCase
    def setup
      @daemon = PumaDaemon.new
    end

    def test_command
      assert_kind_of(CommandLine, @daemon.command)
    end

    def test_motd
      assert_kind_of(String, @daemon.motd)
    end

    def test_root_uri
      assert_kind_of(Ginseng::URI, @daemon.root_uri)
    end
  end
end
