require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run unit specs"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = %w(-fd -c)
  t.pattern = "./spec/unit/**/*_spec.rb"
end

desc "Run integration specs"
RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = %w(-fd -c)
  t.pattern = "./spec/integration/**/*_spec.rb"
end

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(-fd -c)
end

task :default => :unit
task :test => :unit

