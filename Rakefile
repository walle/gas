require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run unit specs"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = %w(-fd -c)
  t.pattern = "./spec/unit/**/*_spec.rb"
end

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(-fd -c)
end

# this is for running tests that you've marked current...  eg:  it 'should work', :current => true do
RSpec::Core::RakeTask.new(:current) do |spec|
  spec.pattern = 'spec/*/*_spec.rb'
  spec.rspec_opts = ['--tag current']
end

task :default => :unit
task :test => :unit