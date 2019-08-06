namespace :mulukhiya do
  namespace :media do
    desc 'clean media cache'
    task :clean do
      Dir.glob(File.join(MulukhiyaTootProxy::Environment.dir, 'tmp/media/*')).each do |path|
        File.unlink(path)
        puts "#{path} deleted"
      rescue => e
        puts "#{path} #{e.class}: #{e.messagee}"
        next
      end
    end
  end
end
