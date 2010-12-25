# Remove unnecessary files
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'public/robots.txt'
remove_file 'public/index.html'
remove_file 'public/images/rails.png'

# Create README
file 'README', <<-README
#{app_name.humanize}
README

# Gemfile
remove_file 'Gemfile'
file 'Gemfile', <<-GEMFILE
source 'http://rubygems.org'

gem 'rails', '#{Rails::VERSION::STRING}'

gem 'sqlite3-ruby', :require => 'sqlite3'

group :development, :test do
  gem 'jquery-rails'
  gem 'rspec-rails', '>= 2.3.1', :group => [:development, :test]
  gem 'shoulda'
end
GEMFILE

# Generators
initializer 'generators.rb', <<-GENERATORS
Rails.application.config.generators do |g|
  g.test_framework = :rspec
end
GENERATORS

# Bundler
run 'bundle install'

# Post Bundle
generate 'jquery:install --force'
generate 'rspec:install'
