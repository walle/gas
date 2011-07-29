require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fd -c)
end

task :default => :spec
task :test => :spec

