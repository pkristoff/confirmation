source 'https://rubygems.org'
ruby '2.5.1'
gem 'rails', '5.2'
gem 'sass-rails'
gem 'uglifier'
# gem 'coffee-rails'
gem 'jquery-rails'
gem 'jbuilder'
group :development, :test do
  gem 'byebug'
end
group :development do
  gem 'web-console'
  gem 'spring'
end
gem 'bootstrap-sass'
gem 'devise'
gem 'high_voltage'
group :development do
  gem 'better_errors'
  gem 'hub', :require=>nil
  # does not exist in rails 5.0
  # gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
end
group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rails_real_favicon'
  gem 'rubocop', require: false
end
group :production do
  gem 'unicorn'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end

gem 'pg', '=0.20'
gem 'rails_12factor', group: :production
gem 'puma'
gem 'roo', '~> 2.4.0'
gem 'zip-zip'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
gem 'tinymce-rails'
gem 'sucker_punch'
gem 'jquery-tablesorter'
# Avoid issues with turbolinks and jquery
gem 'jquery-turbolinks'
gem 'exception_notification'
gem 'prawn'
gem 'rmagick'
group :test do
  gem "i18n-tasks"
end
# refering to master - remove branch
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'
gem 'sendgrid-ruby'
gem 'sdoc'

# Needed for testing controller
group :test do
  gem 'rails-controller-testing'
end