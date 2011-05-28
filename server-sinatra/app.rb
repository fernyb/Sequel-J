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
  
  def table_columns table_name
    results = @mysql.query("SHOW COLUMNS FROM `#{table_name}`")
    names = []
    results.each {|f| names << f[0] }
    names
  end
  
  before do
    self.credentials = params
    @connected = connect ? true : false
  end
  
  
  get '/connect' do
    { connected: @connected, error: @error.to_s, path: request.path_info }.to_json
  end
  
  get '/databases' do
    { connected: @connected, error: @error.to_s, databases: @mysql.list_dbs, path: request.path_info  }.to_json
  end
  
  get '/tables' do
    begin
      { connected: @connected, error: @error.to_s, tables: @mysql.list_tables, path: request.path_info  }.to_json
    rescue Mysql::Error => e
      { connected: @connected, error: e.to_s, tables: [], path: request.path_info  }.to_json
    end
  end
  
  get '/columns/:table' do
    results = @mysql.query("SHOW COLUMNS FROM `#{params[:table]}`")

    columns = []
    results.each{|d|
      columns << {
        :field   => d[0],
        :type    => d[1],
        :null    => d[2],
        :key     => d[3],
        :default => d[4],
        :extra   => d[5]
      }
    }
    
    { connected: @connected, error: @error.to_s, columns: columns, path: request.path_info  }.to_json
  end
  
  get '/header_names/:table' do
    names = table_columns params[:table]
    
    { connected: @connected, error: @error.to_s, header_names: names, path: request.path_info }.to_json
  end
  
  get '/rows/:table' do
    names = table_columns params[:table]
    
    results = @mysql.query("SELECT * FROM `#{params[:table]}` LIMIT 0,100")
    rows = []
    results.each {|f|
      row = {}
      f.each_with_index {|v,idx| row.merge!({ names[idx].to_s => v.to_s }) }
      rows << row
    }
    
    { connected: @connected, error: @error.to_s, path: request.path_info, rows: rows }.to_json
  end
  
  get '/' do
    'Hello World'
  end
end