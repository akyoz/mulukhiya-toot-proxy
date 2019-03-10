namespace :mulukhiya do
  namespace :tagging do
    namespace :dictionary do
      desc 'update tagging dictionary'
      task :update do
        dic = MulukhiyaTootProxy::TaggingDictionary.instance
        dic.delete if dic.exist?
        dic.create
        puts "path: #{MulukhiyaTootProxy::TaggingDictionary.path}"
        puts "#{dic.resources.count} resources"
        puts "#{dic.count} tags"
      end
    end
  end
end
