source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.2', '>= 6.0.2.1'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 4.0.0'
end

group :development do
  gem 'brakeman'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', '0.77.0'
  gem 'rubocop-performance', '~> 1.5.1'
  gem 'rubocop-rails', '~> 2.4.0'
  gem 'rubocop-rspec', '~> 1.37.1'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda-matchers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
