require 'rubygems'
require 'bundler'

Bundler.require

require 'heroku-sinatra-app'
run Sinatra::Application
