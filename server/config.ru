APP_ROOT = File.dirname(__FILE__)

require 'rubygems'

gem 'bundler', '1.0.14'
require 'bundler'

ENVIRONMENT = (ENV['RACK_ENV'] || 'production')
Bundler.require :default, ENVIRONMENT

require "#{APP_ROOT}/ext/mysql.rb"
require "#{APP_ROOT}/app.rb"


set :root, "#{APP_ROOT}"
set :app_file, "#{APP_ROOT}/app.rb"
set :environment, ENVIRONMENT
set :run, false

disable :run, :reload

run App.new