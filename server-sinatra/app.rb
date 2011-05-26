class App < Sinatra::Base
  attr_accessor :credentials
  
  def connect
    @mysql = Mysql.new(credentials['host'], credentials['username'], credentials['password'], credentials['database'])
    rescue Mysql::Error => e
    @error = e
    nil
  end
  
  def credentials
    @credentials ||= {}
  end
  
  def credentials= params
    @credentials = {
      "name"     => '',
      "host"     => '127.0.0.1',
      "username" => '',
      "password" => '',
      "database" => '',
      "port"     => '3306'
    }.merge!(params)
  end
  
  before do
    self.credentials = params
    @connected = connect ? true : false
  end
  
  get '/connect' do
    { connected: @connected, error: @error.to_s }.to_json
  end
  
  get '/databases' do
    { connected: @connected, error: @error.to_s, databases: @mysql.list_dbs }.to_json
  end
  
  get '/tables' do
    begin
      { connected: @connected, error: @error.to_s, tables: @mysql.list_tables }.to_json
    rescue Mysql::Error => e
      { connected: @connected, error: e.to_s, tables: [] }.to_json
    end
  end
  
  get '/' do
    'Hello World'
  end
end