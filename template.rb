# App title
app_title = app_name.underscore.titleize

# User
user=`whoami`

# Remove unnecessary files
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/robots.txt'
remove_file 'public/images/rails.png'
remove_file 'config/database.yml'

# Create README
file 'README.md', <<-README
#{app_title}
README

# RVM
if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    rvm_path     = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
    rvm_lib_path = File.join(rvm_path, 'lib')
    $LOAD_PATH.unshift rvm_lib_path
    require 'rvm'
    run "rvm use 1.9.2-p180@#{app_title.downcase} --rvmrc --create"
    RVM.gemset_use! app_title.downcase
  rescue LoadError
    # RVM is unavailable at this point.
    raise "RVM is currently unavailable, skipping creating a .rvmrc"
  end
end

# PostgreSQL
file 'config/database.yml', <<-DATABASE
common: &common
  adapter: postgresql
  encoding: unicode
  username: #{user}
  password: ""

development:
  <<: *common
  database: #{app_title.downcase}_development

test:
  <<: *common
  database: #{app_title.downcase}_test
DATABASE

# Gemfile
remove_file 'Gemfile'
file 'Gemfile', <<-GEMFILE
source :rubygems

gem 'rails', '#{Rails::VERSION::STRING}'

gem 'jquery-rails'
gem 'pg'

group :development do
  gem 'rails_best_practices'
end

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'watchr'
  gem 'capybara'
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
  g.stylesheets false
  g.fixture true
  g.fixture_replacement :factory_girl
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
    <%= stylesheet_link_tag 'screen.css', :media => 'screen' %>
    <%= csrf_meta_tag %>
  </head>
  <body>
    <div id="header-wrapper">
      <div class="container">
        <div id="header">
          <h1><%= link_to '#{app_title}', root_path %></h1>
          <ul id="nav">
          </ul>
        </div>
      </div>
    </div>
    <div id="content-wrapper">
      <div class="container">
        <div id="content">
        <%- flash.each do |name, msg| -%>
          <%= content_tag :div, msg, :id => "flash-#\{name\}" %>
        <%- end -%>
          <%= yield %>
        </div>
      </div>
    </div>
    <div id="footer-wrapper">
      <div class="container">
        <div id="footer">
        </div>
      </div>
    </div>
    <%= javascript_include_tag :defaults %>
  </body>
</html>
APPLICATION_LAYOUT

# Scaffold Controller Template
file 'lib/templates/rails/scaffold_controller/controller.rb', <<-SCAFFOLD_CONTROLLER
class <%= controller_class_name %>Controller < ApplicationController
  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#\{singular_table_name\}]") %>

    if @<%= orm_instance.save %>
      redirect_to(@<%= singular_table_name %>, :notice => '<%= human_name %> was successfully created.')
    else
      render :action => 'new'
    end
  end

  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    if @<%= orm_instance.update_attributes("params[:#\{singular_table_name\}]") %>
      redirect_to(@<%= singular_table_name %>, :notice => '<%= human_name %> was successfully updated.')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>

    redirect_to(<%= index_helper %>_url)
  end
end
SCAFFOLD_CONTROLLER

# Scaffold ERB Templates
file 'lib/templates/erb/scaffold/edit.html.erb', <<-SCAFFOLD_EDIT_TEMPLATE
<h2>Edit <%= singular_table_name.titleize %></h2>

<%%= render 'form' %>

<p>
<%%= link_to 'Show', @<%= singular_table_name %> %> |
<%%= link_to 'View All', <%= index_helper %>_path %>
</p>
SCAFFOLD_EDIT_TEMPLATE

file 'lib/templates/erb/scaffold/index.html.erb', <<-SCAFFOLD_INDEX_TEMPLATE
<h2><%= plural_table_name.titleize %></h2>

<table>
  <tr>
<% for attribute in attributes -%>
    <th><%= attribute.human_name %></th>
<% end -%>
    <th></th>
    <th></th>
    <th></th>
  </tr>

<%% @<%= plural_table_name %>.each do |<%= singular_table_name %>| %>
  <tr>
<% for attribute in attributes -%>
    <td><%%= <%= singular_table_name %>.<%= attribute.name %> %></td>
<% end -%>
    <td><%%= link_to 'Show', <%= singular_table_name %> %></td>
    <td><%%= link_to 'Edit', edit_<%= singular_table_name %>_path(<%= singular_table_name %>) %></td>
    <td><%%= link_to 'Destroy', <%= singular_table_name %>, :confirm => 'Are you sure?', :method => :delete %></td>
  </tr>
<%% end %>
</table>

<p><%%= link_to 'New <%= human_name %>', new_<%= singular_table_name %>_path %></p>
SCAFFOLD_INDEX_TEMPLATE

file 'lib/templates/erb/scaffold/new.html.erb', <<-SCAFFOLD_NEW_TEMPLATE
<h2>New <%= singular_table_name.titleize %></h2>

<%%= render 'form' %>

<p><%%= link_to 'Back to List', <%= index_helper %>_path %></p>
SCAFFOLD_NEW_TEMPLATE

file 'lib/templates/erb/scaffold/show.html.erb', <<-SCAFFOLD_SHOW_TEMPLATE
<h2><%= singular_table_name.titleize %></h2>

<% for attribute in attributes -%>
<p>
  <strong><%= attribute.human_name %>:</strong>
  <%%= @<%= singular_table_name %>.<%= attribute.name %> %>
</p>

<% end -%>

<p>
<%%= link_to 'Edit', edit_<%= singular_table_name %>_path(@<%= singular_table_name %>) %> |
<%%= link_to 'View All', <%= index_helper %>_path %>
</p>
SCAFFOLD_SHOW_TEMPLATE

file 'lib/generators/factory_girl.rb', <<-FACTORY_GIRL
require 'rails/generators'

Rails::Generators.hidden_namespaces << ['factory_girl:model']
Rails::Generators.hidden_namespaces.flatten!

require 'rails/generators/named_base'

module FactoryGirl
  module Generators
    class Base < Rails::Generators::NamedBase #:nodoc:
      def self.source_root
        @_factory_girl_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'factory_girl', generator_name, 'templates'))
      end
    end
  end
end
FACTORY_GIRL

file 'lib/generators/factory_girl/model/model_generator.rb', <<-MODEL_GENERATOR
require 'generators/factory_girl'

module FactoryGirl
  module Generators
    class ModelGenerator < Base
      argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'
      class_option :dir, :type => :string, :default => 'spec/factories', :desc => 'The directory where the factories should go'

      def create_fixture_file
        begin
          require 'factory_girl'
        rescue LoadError
          raise 'Please install Factory_girl or add it to your Gemfile'
        end

        template 'fixtures.rb', File.join(options[:dir], "#\{table_name\}.rb")
      end
    end
  end
end
MODEL_GENERATOR

file 'lib/generators/factory_girl/model/templates/fixtures.rb', <<-FIXTURES
Factory.define :<%= singular_name %> do |f|
<% for attribute in attributes -%>
  f.<%= attribute.name %> <%= attribute.default.inspect %>
<% end -%>end
FIXTURES

file '.watch', <<-WATCHR
def run_spec(file)
  unless File.exist?(file)
    puts "\#{file} does not exist"
    return
  end

  puts "Running \#{file}"
  system "bundle exec rspec \#{file}"
  puts
end

watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

watch("app/(.*/.*)\.rb") do |match|
  run_spec %{spec/\#{match[1]}_spec.rb}
end
WATCHR


file 'spec/test_spec.rb', <<-SPEC
require 'spec_helper'

describe 'something' do
  pending "add some examples to (or delete) #{__FILE__}"
end
SPEC

# Bundler
run "gem install bundler"
run '(bundle check || bundle install)'

# Post Bundle
generate 'jquery:install -f'
generate 'rspec:install'

# Sanity check
run 'rake db:create:all'
run 'rake db:migrate'
run 'rspec spec'

# Rspec
gsub_file 'spec/spec_helper.rb', /(config.fixture_path)/, '# \1'

# Git
git :init
git :add => "."
git :commit => "-m 'Initial commit'"
