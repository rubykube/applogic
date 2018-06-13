# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bunny',                            '~> 2.9', require: false
gem 'email_validator',                  '~> 1.6'
gem 'figaro',                           '~> 1.1'
gem 'grape',                            '~> 1.0'
gem 'grape-swagger',                    '~> 0.29'
gem 'grape_logging',                    '~> 1.8'
gem 'jwt-multisig',                     '~> 1.0'
gem 'memoist',                          '~> 0.16'
gem 'mini_racer',                       '~> 0.1', require: false
gem 'mysql2',                           '>= 0.3.18', '< 0.5'
gem 'puma',                             '~> 3.7'
gem 'rails',                            '~> 5.2'
gem 'sass-rails',                       '~> 5.0'
gem 'uglifier',                         '~> 4.1'
gem 'validates_lengths_from_database',  '~> 0.7.0'
gem 'faraday',                          '~> 0.15.0'
gem 'faraday_middleware',               '~> 0.12'

group :development, :test do
  gem 'faker',      '~> 1.8'
  gem 'pry-byebug', '~> 3.5'
end

group :test do
  gem 'factory_bot_rails',  '~> 4.8'
  gem 'rspec-rails',        '~> 3.7'
  gem 'rubocop',            '~> 0.55', require: false
  gem 'shoulda-matchers',   '~> 3.1'
  gem 'simplecov',          '0.12.0'
  gem 'webmock',            '~> 3.3'
end

group :development do
  gem 'annotate',              '~> 2.7'
  gem 'grape_on_rails_routes', '~> 0.3'
  gem 'listen',                '>= 3.0.5', '< 3.2'
end
