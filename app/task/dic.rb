namespace :mulukhiya do
  namespace :tagging do
    namespace :dic do
      desc 'update tagging dictionary'
      task :update do
        dic = Mulukhiya::TaggingDictionary.new
        dic.refresh
        puts "#{dic.remote_dics.count} remote dics"
        puts "#{dic.count} tags"
      end
    end
  end
end
