# App name
app_title = app_name.humanize.titleize

# Remove unnecessary files
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'public/robots.txt'
remove_file 'public/index.html'
remove_file 'public/images/rails.png'

# Create README
file 'README', <<-README
#{app_title}
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
  g.helper_specs false
  g.view_specs false
  g.routing_specs false
  g.helper false
  g.request_specs false
  g.stylesheets false
end
GENERATORS

# Default Page
file 'app/controllers/pages_controller.rb', <<-PAGES_CONTROLLER
class PagesController < ApplicationController
end
PAGES_CONTROLLER

file 'app/views/pages/index.html.erb'

# Routes
remove_file 'config/routes.rb'
file 'config/routes.rb', <<-ROUTES
#{app_const}.routes.draw do
  root :to => 'pages#index'
end
ROUTES

# Application Layout
remove_file 'app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-APPLICATION_LAYOUT
<!DOCTYPE html>
<html>
  <head>
    <title>#{app_title}</title>
    <%= stylesheet_link_tag :all %>
    <%= csrf_meta_tag %>
  </head>
  <body>
    <%= yield %>
    <%= javascript_include_tag :defaults %>
  </body>
</html>
APPLICATION_LAYOUT

# Bundler
run 'bundle install'

# Post Bundle
generate 'jquery:install --force'
generate 'rspec:install'
