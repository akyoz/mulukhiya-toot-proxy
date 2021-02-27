module Mulukhiya
  module ControllerMethods
    def self.included(base)
      base.extend(Methods)
    end

    module Methods
      def name
        return to_s.split('::').last.sub(/Controller$/, '').underscore
      end

      def display_name
        return config["/#{name}/display_name"] rescue name
      end

      def webhook?
        return config["/#{name}/features/webhook"] == true rescue false
      end

      def media_catalog?
        return config["/#{name}/features/media_catalog"] == true rescue false
      end

      def feed?
        return config["/#{name}/features/feed"] rescue false
      end

      def growi?
        return Handler.search(/growi/).present?
      end

      def dropbox?
        return Handler.search(/dropbox/).present?
      end

      def announcement?
        return config["/#{name}/features/announcement"] == true rescue false
      end

      def filter?
        return config["/#{name}/features/filter"] == true rescue false
      end

      def futured_tag?
        return config["/#{name}/features/futured_tag"] == true rescue false
      end

      def annict?
        return false unless config["/#{name.underscore}/features/annict"] == true
        return false unless AnnictService.config?
        return true
      rescue Ginseng::ConfigError
        return false
      end

      def livecure?
        return false unless config['/programs/url'].present?
        return true
      rescue Ginseng::ConfigError
        return false
      end

      def dbms_name
        return config["/#{name}/dbms"]
      end

      def dbms_class
        return "Mulukhiya::#{dbms_name.camelize}".constantize
      end

      def parser_name
        return config["/#{name}/status/parser"]
      end

      def parser_class
        return "Mulukhiya::#{parser_name.camelize}Parser".constantize
      end

      def oauth_webui_uri
        return Ginseng::URI.parse(config["/#{name.underscore}/oauth/webui/url"]) rescue nil
      end

      def oauth_default_scopes
        return config["/#{name}/oauth/scopes"] || [] rescue nil
      end

      def status_field
        return config["/parser/#{parser_name}/fields/body"]
      end

      def poll_options_field
        return config["/parser/#{parser_name}/fields/poll/options"]
      end

      def spoiler_field
        return config["/parser/#{parser_name}/fields/spoiler"]
      end

      def attachment_field
        return config["/parser/#{parser_name}/fields/attachment"]
      end

      def attachment_limit
        return config["/#{name}/attachment/limit"]
      end

      def status_key
        return config["/#{name}/status/key"]
      end

      def status_label
        return config["/#{name}/status/label"]
      end

      def default_image_type
        return config["/#{name}/attachment/types/image"] rescue nil
      end

      def default_video_type
        return config["/#{name}/attachment/types/video"] rescue nil
      end

      def default_audio_type
        return config["/#{name}/attachment/types/audio"] rescue nil
      end

      def default_animation_image_type
        return config["/#{name}/attachment/types/animation_image"] rescue nil
      end

      def visibility_name(name)
        return parser_class.visibility_name(name)
      end
    end
  end
end
