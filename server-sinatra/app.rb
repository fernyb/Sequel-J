require 'sinatra'
require 'json'

class App < Sinatra::Base
  
  get '/' do
    'Hello World'
  end
end