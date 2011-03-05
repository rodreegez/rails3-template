# App title
app_title = app_name.underscore.titleize

# Remove unnecessary files
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/robots.txt'
remove_file 'public/images/rails.png'

# Create README
file 'README.md', <<-README
#{app_title}
README

# Gemfile
remove_file 'Gemfile'
file 'Gemfile', <<-GEMFILE
source 'http://rubygems.org'

gem 'rails', '#{Rails::VERSION::STRING}'

gem 'compass'
gem 'jquery-rails'
gem 'simple_form'
gem 'sqlite3-ruby', :require => 'sqlite3'

group :development, :test do
  gem 'rails3-generators'
  gem 'rspec-rails', '>= 2.3.1'
end

group :test do
  gem 'autotest'
  gem 'capybara'
  gem 'factory_girl_rails', '1.1.beta1'
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
  g.fixture_replacement :factory_girl, :dir => 'spec/factories'
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

# Bundler
run 'bundle install'

# Post Bundle
generate 'jquery:install -f'
generate 'rspec:install'
generate 'simple_form:install'

# Rspec
gsub_file 'spec/spec_helper.rb', /(config.fixture_path)/, '# \1'

# Compass
run 'compass init rails --sass-dir=app/stylesheets --css-dir=public/stylesheets/'
remove_file 'app/stylesheets/screen.scss'
remove_file 'app/stylesheets/print.scss'
remove_file 'app/stylesheets/ie.scss'
append_file '.gitignore', '/public/stylesheets/*.css'
file 'app/stylesheets/screen.scss', <<-CSS
@import "compass/reset";
@import "blueprint/grid";
@import "blueprint/typography";
@import "blueprint/interaction";
@import "blueprint/form";
@import "compass/css3";
@import "compass/utilities";

$header-background-color: #145599;
$content-background-color: #fff;
$body-background-color: #eee;

$blueprint-font-family: 'Lucida Grande', 'Helvetica Neue', Helvetica, Arial, sans-serif;
$font-size: 14px;
$font-color: #333;

$headings-font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
$headings-color: #333;

$header-title-color: #fff;

@mixin unstyled-link-with-pointer {
  color: inherit;
  text-decoration: inherit;
  &:active, &:focus {
    outline: none;
  }
}

@mixin blueprint-form-number-input($unfocused_border_color: #bbbbbb, $focus_border_color: #666666, $input_width: 300px) {
  input {
    &[type=number] {
      position: relative;
      top: 0.25em;
      width: $input_width;
      margin: 0.5em 0;
      background-color: white;
      padding: 5px;
      border: 1px solid $unfocused_border_color;
      &:focus {
        border: 1px solid $focus_border_color;
      }
    }
  }
}

body {
  background-color: $body-background-color;
  @include blueprint-typography;
  @include blueprint-typography-body($font-size);

  #\{headings()\} {
    color: $headings-color;
    font-family: $headings-font-family;
    font-weight: bold;
  }

  h1 {
    letter-spacing: -2px;
  }

  h2 {
    letter-spacing: -1px;
  }
}

#header-wrapper {
  background-color: $header-background-color;
  @include linear-gradient(color-stops(darken($header-background-color, 10), $header-background-color));
}

#content-wrapper {
  background-color: $content-background-color;
}

#footer-wrapper {
  @include linear-gradient(color-stops(darken($body-background-color, 10), $body-background-color));
  clear: both;
  height: 100px;
}

.container {
  @include container;
}

#header, #content, #footer {
  @include column(24);
  @include prepend-top;
  @include append-bottom;
}

#header {
  h1 {
    float: left;
    @include text-shadow(rgba(#000,.3), 1px, 1px, 4px);
    margin-bottom: 0;
    color: $header-title-color;
    a {
      @include link-colors($header-title-color, $header-title-color, $header-title-color, $header-title-color);
      @include unstyled-link-with-pointer;
    }
  }

  #nav {
    float: right;
    list-style: none;

    li {
      float: left;
      margin: 0 0 0 5px;

      a {
        @include unstyled-link-with-pointer;
        padding: 5px 15px;
        font-weight: bold;
        color: $header-title-color;
        color: rgba($header-title-color, 0.8);
        text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5);
        @include border-radius(14px);
        @include transition(all, 0.3s, ease-in-out);
      }

      a:hover, li a:focus {
        background: rgba($header-title-color, 0.15);
      }
    }
  }
}

#content {
  min-height: 300px;
}

#footer {
  @include quiet;
  font-size: $blueprint-font-size - 2px;
  text-align: center;
}

#flash-notice {
  @include success;
}

#flash-alert {
  @include error;
}

.simple_form, .form {
  @include blueprint-form;
  @include blueprint-form-number-input;

  :focus {
    outline: 0 none;
  }

  abbr {
    border-bottom: none;
  }

  input, textarea {
    display: block;
  }

  div.input, div.actions {
    @include append-bottom;
  }

  .error {
    font-size: $blueprint-font-size;
    color: #D00;
    display: block;
  }

  .hint {
    @include quiet;
    font-size: $blueprint-font-size;
    display: block;
    font-style: italic;
  }
}
CSS

# Git
git :init
git :add => "."
git :commit => "-m 'Initial commit'"
