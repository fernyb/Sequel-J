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
  
  def query str
    @mysql ? @mysql.query(str) : []
    rescue Mysql::Error => e
    @error = e
    []
  end
  
  def table_columns table_name
    results = @mysql.query("SHOW COLUMNS FROM `#{table_name}`")
    names = []
    results.each {|f| names << f[0] }
    names
  end
  
  def sql_for_table table_name
    results = query "SHOW CREATE TABLE `#{table_name}`"
    result = []
    sql = ""
    results.each {|item| result = item }
    sql = result[1] if result.size == 2
    sql
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
    begin
      render databases: @mysql.list_dbs
    rescue Mysql::Error => e
      render databases: []
    end
  end
  
  get '/tables' do
    begin
      render tables: @mysql.list_tables
    rescue Mysql::Error => e
      render tables: []
    end
  end
  
  get '/columns/:table' do
    results = query "SHOW COLUMNS FROM `#{params[:table]}`"
    
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
    results = query "SELECT * FROM `#{params[:table]}` LIMIT 0,100"
    
    rows = []
    results.each {|f|
      row = {}
      f.each_with_index {|v,idx| row.merge!({ names[idx].to_s => v.to_s }) }
      rows << row
    }
    
    render rows: rows
  end
  
  get '/schema/:table' do
    results = query "SHOW COLUMNS FROM `#{params[:table]}`"
  
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
    results = query "SHOW INDEX FROM `#{params[:table]}`"
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
  
  
  get '/relations/:table' do
    sql = sql_for_table params[:table]
    parts = sql.split("\n").map {|part| part.strip }
    constraints = parts.select {|part| part =~ /^CONSTRAINT/ }

    relations = constraints.map do |part|
      row = {
        name:          '',
        foreign_key:   [],
        reference_key: [],
        on_delete:     '',
        on_update:     ''
      }
      row.merge!({ name: $1 }) if part =~ /CONSTRAINT `([0-9a-z_\-\+\=\%]+)`/i
    
      if part =~ /FOREIGN KEY \(/i
        fields = part.split("FOREIGN KEY (").last.split(")").first
        fields = fields.scan(/`([\w\-]+)`/i).flatten
        row.merge!({ foreign_key: fields })
      end

      if part =~ /REFERENCES `([0-9a-z_\-\+\=\%]+)`/i
        row.merge!({ reference_table: $1 })
        fields = part.split("REFERENCES").last
        fields = fields.scan(/\`([\w\-]+)`/i).flatten
        fields.shift    
        row.merge!({ reference_key: fields })
      end
      
      row.merge!({ on_delete: $1 }) if part =~ /ON DELETE (RESTRICT|CASCADE|SET NULL|NO ACTION)/i
      row.merge!({ on_update: $1 }) if part =~ /ON UPDATE (RESTRICT|CASCADE|SET NULL|NO ACTION)/i
      row.size > 0 ? row : nil
    end.reject {|item| item.nil? }
  
    render relations: relations
  end
  
  get '/show_create_table/:table' do
    sql = sql_for_table params[:table]
    render sql: sql
  end
  
  get '/' do
    'Hello World'
  end
end