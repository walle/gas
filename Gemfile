source :rubygems
gemspec

group :test do
  gem 'yard'
  gem 'guard'
  gem 'guard-rspec'
  gem 'simplecov', :require => false
  gem 'webmock'
  gem 'vcr'
  if RUBY_PLATFORM =~ /linux/i
    gem 'rb-inotify'
    gem 'libnotify'
  end
end

