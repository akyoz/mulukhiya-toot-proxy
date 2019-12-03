dir = File.expand_path(__dir__)
$LOAD_PATH.unshift(File.join(dir, 'app/lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(dir, 'Gemfile')

require 'bundler/setup'
require 'mulukhiya_toot_proxy'

[:start, :stop, :restart].each do |action|
  desc "#{action} all"
  task action => ["mulukhiya:thin:#{action}", "mulukhiya:sidekiq:#{action}"]
end

Dir.glob(File.join(MulukhiyaTootProxy::Environment.dir, 'app/task/*.rb')).each do |f|
  require f
end
