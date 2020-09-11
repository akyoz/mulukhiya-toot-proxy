module Mulukhiya
  class SlimRenderer < Ginseng::Web::SlimRenderer
    include Package

    def initialize(template = nil)
      Slim::Engine.set_options(
        pretty: Environment.development?,
      )
      super
    end

    def self.render(name, values = {})
      slim = SlimRenderer.new(name)
      slim.params.merge!(values)
      return slim.to_s
    rescue Ginseng::RenderError
      return nil
    end

    def self.create_uri(path)
      return Environment.sns_class.new.create_uri(path)
    end

    private

    def assign_values
      return {
        params: params,
        slim: SlimRenderer,
        package: Package,
        controller: Environment.controller_class,
        env: Environment,
        crypt: Crypt,
        config: @config,
        annict: AnnictService.new,
        scripts: @config['/webui/scripts'],
        stylesheets: @config['/webui/stylesheets'],
        metadata: @config.raw.dig('application', 'webui', 'metadata'),
      }
    end
  end
end
