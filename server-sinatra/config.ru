APP_ROOT = File.dirname(__FILE__)

require 'rubygems'
require 'bundler'

Bundler.require

require "#{APP_ROOT}/app.rb"

set :root, "#{APP_ROOT}"
set :app_file, "#{APP_ROOT}/app.rb"
set :environment, ENV['RACK_ENV'] || :production
set :run, false

disable :run, :reload

run App.new