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
  
  def render kv={}
    { connected: @connected, error: @error.to_s, path: request.path_info }.merge!(kv).to_json
  end
  
  before do
    self.credentials = params
    @connected = connect ? true : false
  end
  
  
  get '/connect' do
    render
  end
  
  get '/databases' do
    render databases: @mysql.list_dbs
  end
  
  get '/tables' do
    begin
      render tables: @mysql.list_tables
    rescue Mysql::Error => e
      render tables: []
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
    
    render columns: columns
  end
  
  get '/header_names/:table' do
    names = table_columns params[:table]
    render header_names: names
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
    
    render rows: rows
  end
  
  get '/schema/:table' do
    results = @mysql.query("SHOW COLUMNS FROM `#{params[:table]}`")
    fields = []
    results.each {|row|
      fields << {
        'Field'      => row[0],
        'Type'       => (row[1] =~ /([a-z]+)/i ? $1 : ''),
        'Length'     => (row[1] =~ /([0-9]+)/ ? $1 : ''),
        'Unsigned'   => (row[1] =~ /unsigned/i ? true : false),
        'Zerofill'   => (row[1] =~ /zerofill/i ? true : false),
        'Binary'     => false, # I don't know what this field is for?
        'Allow Null' => (row[2].to_s == 'YES'),
        'Key'        => row[3].to_s,
        'Default'    => (row[4].nil? ? 'NULL' : row[4]),
        'Extra'      => row[5]
      } 
    }
    
    render fields: fields
  end
  
  get '/indexes/:table' do
    results = @mysql.query("SHOW INDEX FROM `#{params[:table]}`")
    fields = []
    results.each {|row|
      fields << {
        'Non_unique'   => row[1],
        'Key_name'     => row[2],
        'Seq_in_index' => row[3],
        'Column_name'  => row[4],
        'Collation'    => row[5],
        'Cardinality'  => row[6],
        'Sub_part'     => row[7].nil? ? 'NULL' : row[7],
        'Packed'       => row[8].nil? ? 'NULL' : row[8],
        'Null'         => row[9],
        'Index_type'   => row[10],
        'Comment'      => row[11]
      }
    }
    
    render indexes: fields 
  end
  
  get '/' do
    'Hello World'
  end
end