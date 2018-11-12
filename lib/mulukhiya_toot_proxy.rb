require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'

module MulukhiyaTootProxy
  extend ActiveSupport::Autoload

  autoload :AmazonService
  autoload :Config
  autoload :Handler
  autoload :ImageHandler
  autoload :ItunesService
  autoload :Logger
  autoload :Mastodon
  autoload :NowplayingHandler
  autoload :Package
  autoload :Renderer
  autoload :Server
  autoload :Slack
  autoload :SpotifyService
  autoload :UrlHandler

  autoload_under 'error' do
    autoload :ConfigError
    autoload :ExternalServiceError
    autoload :ImprementError
    autoload :NotFoundError
    autoload :RequestError
  end

  autoload_under 'renderer' do
    autoload :JsonRenderer
  end

  autoload_under 'uri' do
    autoload :AmazonUri
    autoload :ItunesUri
    autoload :SpotifyUri
  end
end