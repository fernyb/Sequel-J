ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
require 'sinatra'
require 'rack/test'
require 'rspec'

Bundler.require :default, ENV['RACK_ENV']

%W(app ext/mysql).each do |file|
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