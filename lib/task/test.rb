namespace :mulukhiya do
  desc 'mulukhiya test'
  task :test do
    ENV['TEST'] = MulukhiyaTootProxy::Package.full_name
    require 'test/unit'
    Dir.glob(File.join(MulukhiyaTootProxy::Environment.dir, 'test/*')).each do |t|
      require t
    end
  end
end
