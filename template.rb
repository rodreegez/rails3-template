# App title
app_title = app_name.humanize.titleize

# Remove unnecessary files
remove_file 'README'
remove_file 'public/index.html'
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

gem 'compass'
gem 'simple_form'
gem 'sqlite3-ruby', :require => 'sqlite3'

group :development, :test do
  gem 'rails3-generators'
  gem 'rspec-rails', '>= 2.3.1'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'factory_girl_rails'
  gem 'shoulda'
end
GEMFILE

# Generators
initializer 'generators.rb', <<-GENERATORS
Rails.application.config.generators do |g|
  g.test_framework = :rspec
  g.helper_specs false
  g.view_specs false
  g.helper false
  g.request_specs false
  g.stylesheets false
  g.fixture true
  g.fixture_replacement = :factory_girl
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
    <%= stylesheet_link_tag 'screen.css', :media => 'screen, projection' %>
    <%= csrf_meta_tag %>
  </head>
  <body>
    <h1><%= link_to '#{app_title}', root_path %></h1>
    <%- flash.each do |name, msg| -%>
      <%= content_tag :div, msg, :class => "#\{name\}" %>
    <%- end -%>
    <%= yield %>
    <%= javascript_include_tag :defaults %>
  </body>
</html>
APPLICATION_LAYOUT

# jQuery
inside 'public/javascripts' do
  get 'https://github.com/rails/jquery-ujs/raw/master/src/rails.js', 'rails.js'
  get 'http://code.jquery.com/jquery-1.4.4.js', 'jquery.js'
end

gsub_file 'config/application.rb', /config\.action_view\.javascript.*\n/, "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)\n"

# Bundler
run 'bundle install'

# Post Bundle
generate 'rspec:install'
generate 'cucumber:install --capybara --rspec'
generate 'simple_form:install'

# Cucumber Factory Girl integration
append_file 'features/support/env.rb', "\nrequire 'factory_girl/step_definitions'" 

# Compass
run 'compass init rails --sass-dir=app/stylesheets --css-dir=public/stylesheets/'
remove_file 'app/stylesheets/screen.scss'
remove_file 'app/stylesheets/print.scss'
remove_file 'app/stylesheets/ie.scss'
file 'app/stylesheets/screen.scss', <<-CSS
@import "compass/reset";
CSS

# Git
git :init
git :add => "."
git :commit => "-m 'Initial commit'"
