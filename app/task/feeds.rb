namespace :mulukhiya do
  namespace :tagging do
    namespace :feeds do
      desc 'update feeds'
      task :update do
        if Mulukhiya::Environment.controller_class.feed?
          Mulukhiya::TagAtomFeedRenderer.cache_all
          Mulukhiya::TagAtomFeedRenderer.all do |renderer|
            puts "updated: ##{renderer.tag} #{renderer.path}"
          end
        else
          warn "#{Mulukhiya::Environment.controller_class.name} doesn't support feeds."
          exit 1
        end
      end
    end
  end
end
