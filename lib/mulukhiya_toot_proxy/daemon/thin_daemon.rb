require 'daemon_spawn'

module MulukhiyaTootProxy
  class ThinDaemon < DaemonSpawn::Base
    def start(args)
      system('thin', '--config', ThinDaemon.config_path, 'start')
    end

    def stop
      system('pkill', '-f', ThinDaemon.config_path)
    end

    def self.config_path
      return File.join(Environment.dir, 'config/thin.yaml')
    end
  end
end
