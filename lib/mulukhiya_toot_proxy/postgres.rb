module MulukhiyaTootProxy
  class Postgres < Ginseng::Postgres::Database
    include Package

    def execute(name, params = {})
      return super(name, params).map(&:with_indifferent_access)
    end

    def self.dsn
      return Ginseng::Postgres::DSN.parse(Config.instance['/postgres/dsn'])
    end

    def self.health
      Account.new(token: Config.instance['/test/token'])
      return {status: 'OK'}
    rescue
      return {status: 'NG'}
    end
  end
end
