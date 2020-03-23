module Mulukhiya
  class SlimRenderer < Ginseng::Web::SlimRenderer
    include Package

    def self.render(name, values = {})
      slim = SlimRenderer.new(name)
      slim.params.merge!(values)
      return slim.to_s
    rescue Ginseng::RenderError
      return nil
    end

    private

    def assign_values
      return {
        params: params,
        slim: SlimRenderer,
        package: Package,
        controller: Environment.controller_class,
        crypt: Crypt,
        scripts: @config['/webui/scripts'],
        stylesheets: @config['/webui/stylesheets'],
        metadata: @config.raw.dig('application', 'webui', 'metadata'),
      }
    end
  end
end