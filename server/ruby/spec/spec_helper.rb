ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'mysql'

Bundler.require :default, ENV['RACK_ENV']

%W(
  modules/app_module 
  ext/mysql 
  ext/array 
  ext/hash 
  app
).each do |file|
  require File.join(File.dirname(__FILE__), '..', "#{file}.rb")
end

# set test environment
set :environment, ENV['RACK_ENV']
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
