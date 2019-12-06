module MulukhiyaTootProxy
  class Postgres < Ginseng::Postgres::Database
    include Package

    def execute(name, params = {})
      return super(name, params).map(&:with_indifferent_access)
    end

    def self.connect
      return instance
    end

    def self.config?
      return Postgres.dsn.present?
    end

    def self.dsn
      return Ginseng::Postgres::DSN.parse(Config.instance['/postgres/dsn'])
    rescue Ginseng::ConfigError => e
      return nil
    end

    def self.health
      Account.get(token: Config.instance['/test/token'])
      return {status: 'OK'}
    rescue
      return {status: 'NG'}
    end
  end
end
