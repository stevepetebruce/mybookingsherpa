source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.0"

gem "rails", "~> 6.0.3"

gem "aws-sdk-s3", require: false
gem "bootsnap", ">= 1.4.6", require: false
gem "country_select", "~> 4.0"
gem "devise", ">= 4.6.0"
gem "faker" # TODO: move back to :development, :test, after user testing.
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.12"
gem "rack-attack"
gem "rollbar"
gem "sidekiq"
gem "skylight"
gem "stripe"
gem "webpacker", "~> 4.x"

group :development, :test do
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "pry"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "shoulda-matchers", ">= 4.3.0"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rb-readline"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "simplecov", require: false
  gem "webmock"
end
