source 'http://rubygems.org'

ruby '2.5.0'

gem 'sinatra'
gem 'activerecord', '~> 5.2', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'bcrypt'
gem 'sinatra-flash'
gem 'rails_12factor'
gem 'dotenv'
gem 'pg', '~> 0.20.0'

group :development do
  gem 'shotgun'
  gem 'tux'
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end
