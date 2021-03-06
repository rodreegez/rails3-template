# Rails 3 Template

A Rails 3 application template

## Usage

`rails new APP_NAME -m template.rb -T`

## What it does
* Removes files from public
* Creates a clean README
* Removes commented lines from the Gemfile
* Switches from Test::Unit to RSpec
* Installs Shoulda
* Insatlls pg for PostgreSQL
* Changes generators to not create stylesheets or helpers
* Changes RSpec generators to not create helper or view specs
* Creates a PagesController and blank index view
* Sets root route to pages#index
* Application layout includes flash messages, page title, and script tags moved to bottom of the body
* Scaffold controller templates don't include respond_to blocks
* Removes flash messages from ERB Templates, cleans up scaffold views
* Switches from Prototype to jQuery
* Creates a git repository and does an initial commit
