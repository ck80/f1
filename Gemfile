source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use postgresql
gem 'pg', '~> 1.3'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'
gem 'sassc'

# add dotenv-rails
gem 'dotenv'
gem 'dotenv-rails', require: 'dotenv/rails-now'

# bootstrap
gem 'bootstrap', '~> 5.1.3'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tablesorter', '~> 1.27'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes

# gem 'therubyracer', platforms: :ruby

gem 'mini_racer'

gem 'pry-rails', :group => :development

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.17'
gem 'bootstrap_form', '~> 4.5'
gem 'devise', '~> 4.8'
gem 'recaptcha'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Web scraping Gems
gem "nokogiri", ">= 1.8.5"
# gem 'csv'
# gem 'find'
gem 'sanitize', '~> 5.2.1'

# icalendar parsing
gem 'icalendar', '~> 2.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# add job scheduler
gem 'delayed_job_active_record'

# add figaro for environment variables
# gem 'figaro'



group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.36'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.8'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end


