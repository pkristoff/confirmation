# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.0'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
gem 'bootstrap'
gem 'coffee-rails'
gem 'devise'
# Avoid issues with turbolinks and jquery
gem 'exception_notification'
gem 'high_voltage'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-tablesorter'
gem 'jquery-turbolinks'
gem 'pg', '=0.20'
gem 'prawn'
gem 'puma'
gem 'rails', '5.2.3'
gem 'rmagick'
gem 'roo', '~> 2.4.0'
gem 'sass-rails'
gem 'sdoc'
gem 'sendgrid-ruby'
gem 'sprockets', '~> 3.7.2'
gem 'tinymce-rails'
gem 'uglifier'
gem 'zip-zip'
# refering to master - remove branch
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'
gem 'sucker_punch'
group :development do
  gem 'better_errors'
  gem 'debase'
  gem 'hub', require: nil
  # does not exist in rails 5.0
  # gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
end
group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rails_real_favicon'
  gem 'rspec-rails'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end
group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'i18n-tasks'
  gem 'launchy'
  gem 'selenium-webdriver'
end
