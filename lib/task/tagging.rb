namespace :mulukhiya do
  namespace :tagging do
    namespace :dictionary do
      desc 'update tagging dictionary'
      task :update do
        dic = MulukhiyaTootProxy::TaggingDictionary.new
        dic.delete if dic.exist?
        dic.create
        puts "path: #{dic.path}"
        puts "#{dic.resources.count} resources"
        puts "#{dic.count} tags"
      end
    end
  end
end
