module Mulukhiya
  class RSS20FeedRenderer < Ginseng::Web::RSS20FeedRenderer
    include Package
    include SNSMethods

    def initialize(channel = {})
      super
      @sns = sns_class.new
      @channel[:author] = @sns.info['metadata']['maintainer']['name']
      @channel[:title] = channel['title']
      @channel[:description] = channel['description']
      return unless channel['link']
      @http.base_uri = URI.parse(channel['link'])
      @channel[:link] = @http.base_uri.to_s
    end
  end
end
