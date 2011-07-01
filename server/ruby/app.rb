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
  
  def schema_table table_name
    results = query "SHOW COLUMNS FROM `#{table_name}`"
    fields = results.map {|row|
      {
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
    fields
  end
  
  def table_indexes table_name
    results = query "SHOW INDEX FROM `#{table_name}`"
    fields = results.map {|row|
      {
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
    fields
  end
  
  def table_columns table_name
    results = query("SHOW COLUMNS FROM `#{table_name}`")
    results.collect {|f| f[0] }
  end
  
  def sql_for_table table_name
    results = query "SHOW CREATE TABLE `#{table_name}`"
    results = results.collect {|f| f }.flatten
    results.size == 2 ? results.last : ''
  end
  
  def database_list_tables
    begin
      @mysql.list_tables
    rescue Mysql::Error => e
      @error = e
      []
    end
  end
  
  def render kv={}
    { connected: @connected, error: @error.to_s, path: request.path_info }.merge!(kv).to_json
  end
 
  def send_data(data, options={})
    status       options[:status]   if options[:status]
    attachment   options[:filename] if options[:disposition] == 'attachment'
    content_type options[:type]     if options[:type]
    halt data
  end
  
  def handle_api_path
    endpoint_name = params.delete('endpoint')
    table_name    = params.delete('table')
    
    endpoint_path = "/#{endpoint_name}"
    endpoint_path << "/#{table_name}" if table_name
    endpoint_path << "?" << params.to_query_string if params.keys.size > 0
  
    redirect to(endpoint_path), 307
  end

  before do
    unless /api\.php/ =~ request.path_info
      self.credentials = params
      @connected = connect ? true : false
    end
  end
  
  get '/api.php' do
    handle_api_path
  end
  
  post '/api.php' do
    handle_api_path
  end
  
  get '/connect' do
    results = query "SHOW CHARACTER SET"    
    rows = results.rows
    render character_sets: rows
  end
  
  get '/databases' do
    begin
      render databases: @mysql.list_dbs
    rescue Mysql::Error => e
      @error = e
      render databases: []
    end
  end
  
  get '/tables' do
    begin
      render tables: @mysql.list_tables
    rescue Mysql::Error => e
      @error = e      
      render tables: []
    end
  end
  
  post '/add_table/:table' do
    q = "CREATE TABLE `#{params[:table]}` (id INT NOT NULL)"
    q << " DEFAULT CHARACTER SET `#{params['table_encoding']}`" if params['table_encoding'] != ''
    q << " ENGINE = `#{params['table_type']}`" if params['table_type'] != ''
    
    query q
    tables = database_list_tables
    render tables: tables
  end
  
  post '/remove_table/:table' do
    query "DROP TABLE `#{params[:table]}`"
    tables = database_list_tables
    render tables: tables
  end
  
  post '/truncate_table/:table' do
    query "TRUNCATE TABLE `#{params[:table]}`"
    tables = database_list_tables
    render tables: tables
  end
  
  get '/columns/:table' do
    results = query "SHOW COLUMNS FROM `#{params[:table]}`"
    columns = results.map {|d|
      {
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
    orderby = if params['order_by']
      " ORDER BY `#{params['order_by']}` " << (params['order'] == 'ASC' ? 'ASC ' : 'DESC ')
    else
      ' '
    end
  
    results = query "SELECT * FROM `#{params[:table]}`#{orderby}LIMIT 0,100"
    rows = results.map {|f|
      f = f.map {|v| v.nil? ? '' : v }
      Hash[*names.zip(f).flatten]
    }
    
    render rows: rows
  end
  
  get '/schema/:table' do
    fields = schema_table params[:table]    
    render fields: fields
  end
  
  post '/schema/:table' do
    name     = params['name']
    field    = params['field']
    type     = params['type']
    length   = params['length']
    extra    = params['extra']
    unsigned = params['unsigned']
    allow_null = params['null'] == 'YES' ? 'NULL' : 'NOT NULL'
    result  = ''
    qstr = ''
  
    if params[name] == 'YES'
      name = '' if name.upcase == 'ALLOW NULL'
      qstr = "ALTER TABLE `#{params['table']}` CHANGE `#{field}` `#{field}` #{type}(#{length}) #{name.upcase} #{allow_null} #{extra}"
    elsif params[name] == 'NO'
      qstr = "ALTER TABLE `#{params['table']}` CHANGE `#{field}` `#{field}` #{type}(#{length}) #{allow_null} #{extra}"
    else
      qstr = "ALTER TABLE `#{params['table']}` CHANGE `#{field}` `#{field}` #{type}(#{length})"
      qstr << " UNSIGNED" if unsigned == "YES"
      qstr << " NOT NULL"
      qstr << " auto_increment" if extra == 'auto_increment'
      qstr << " on update CURRENT_TIMESTAMP" if extra == 'on update CURRENT_TIMESTAMP'
    end
    query qstr
    
    fields = ((@error == '' || @error.nil?) ? schema_table(params[:table]) : [])
    
    render fields: fields, query: qstr
  end
  
  get '/indexes/:table' do
    fields = table_indexes params[:table]
    render indexes: fields
  end
  
  post '/add_index/:table' do
    query "ALTER TABLE `#{params[:table]}` ADD #{params['type'].upcase} `#{params['name']}` (`#{params['index_column']}`)"
    fields = table_indexes params[:table]
    render indexes: fields
  end
  
  post '/remove_index/:table' do
    query "ALTER TABLE `#{params[:table]}` DROP INDEX `#{params['name']}`"
    fields = table_indexes params[:table]
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

  get '/table_info/:table' do
    results = query "SHOW TABLE STATUS LIKE '#{params[:table]}'"
    status = results.map {|item|
      item = item.map {|value| value.nil? ? '' : value }
      {
        name:            item[0],
        engine:          item[1],
        version:         item[2],
        row_format:      item[3],
        rows:            item[4],
        avg_row_length:  item[5],
        data_length:     item[6],
        max_data_length: item[7],
        index_length:    item[8],
        data_free:       item[9],
        auto_increment:  item[10],
        create_time:     item[11],
        update_time:     item[12],
        check_time:      item[13],
        collation:       item[14],
        checksum:        item[15],
        create_options:  item[16],
        comment:         item[17]
      }
    }.first
    
    if status
      result = query "SELECT Engine, Support FROM information_schema.engines WHERE support IN ('DEFAULT', 'YES')"
      engines = result.map {|item| item.first }
      
      result = query "SELECT * FROM information_schema.character_sets ORDER BY character_set_name ASC"
      encodings = result.map {|item| {collation_name: item[0], collate_set_name: item[1], description: item[2]} }
      char_set = encodings.select {|item| item[:collate_set_name].split("_").first == status[:collation].split("_").first }.first
      if char_set
        result = query "SELECT * FROM information_schema.collations WHERE character_set_name = '#{char_set[:collation_name]}' ORDER BY 'collation_name' ASC"
        collations = result.map {|item| {collation_name: item[0], character_set_name: item[1], id: item[2]} }
      end
    end
    
    sql = sql_for_table params[:table]
    encodings  ||= []
    collations ||= []
    status     ||= ''
    engines    ||= ''
    char_set   ||= {collation_name: '', collate_set_name: '', description: ''}
    
    render status: status, charset: char_set[:collation_name], engines: engines, encodings: encodings, collations: collations, sql: sql
  end
  
  get '/character_sets' do
    results = query "SHOW CHARACTER SET"
    rows = results.rows
    render character_sets: rows
  end
  
  get '/query' do
    results = query params[:query]
    fields  = results.fields
    rows    = results.rows
    render columns: fields, results: rows
  end
  
  get '/export' do
    if params['type'] == 'sql_history'
      json = JSON.parse(params['json'])
      send_data json.join("\n"), type: 'application/json', disposition: 'attachment', filename: 'history.sql'
    end
    render
  end
  
  post '/update_table/:table' do
    if params.key?('type')
      query("ALTER TABLE `#{params['table']}` TYPE = #{params['type']}")
      render type: params['type']
    elsif params.key?('encoding')
      query("ALTER TABLE `#{params['table']}` CHARACTER SET = #{params['encoding']}")
      render encoding: params['encoding']
    elsif params.key?('collation')
      query("ALTER TABLE `#{params['table']}` COLLATE = #{params['collation']}")
      render collation: params['collation']
    end
  end
  
  post '/updatecolumn/:table' do  
    qstr = "ALTER TABLE `#{params[:table]}` "    
    update_column_name = params['update_column_name']
    
    if update_column_name == 'Type'
      params['column_length'] = '255' if params['column_length'] == ''
      qstr << "CHANGE `#{params['column_name']}` `#{params['column_name']}` #{params['column_type']}(#{params['column_length']}) "
    elsif update_column_name == 'Length'
      qstr << "CHANGE `#{params['column_name']}` `#{params['column_name']}` #{params['column_type']}(#{params['column_length']}) "  
    elsif update_column_name == 'Field'
      if params['action_name'] == 'duplicate' || params['action_name'] == 'add'
        qstr << "ADD `#{params['column_name']}` "
        qstr << (params['column_length'] == '' ? "#{params['column_type']} " : "#{params['column_type']}(#{params['column_length']}) ")  
      else
        qstr << "CHANGE `#{params['previous_value']}` `#{params['column_name']}` #{params['column_type']} "
      end
    elsif update_column_name == 'Default'
      qstr << "CHANGE `#{params['column_name']}` `#{params['column_name']}` #{params['column_type']}(#{params['column_length']}) "
    else
      fields = schema_table(params[:table])
      name = fields.detect {|item| item['Field'] == params['previous_value'] }
      
      if name.nil?
        qstr << "ADD `#{params['column_name']}` #{params['column_type']} "
      else
        qstr << "CHANGE `#{params['previous_value']}` `#{params['column_name']}` #{params['column_type']}(#{params['column_length']}) "
      end
    end

    qstr << "NULL DEFAULT "
    if params['column_default'].nil? || params['column_default'] == '' || params['column_default'] == 'NULL'
      qstr << "NULL "
    else
      qstr << "'#{params['column_default']}' "
    end
    qstr << "AFTER `#{params['after_column_name']}`" if params['after_column_name'] != ''
    
    query(qstr)
    fields = schema_table(params[:table])
    render fields: fields, query: qstr
  end
  
  post '/removecolumn/:table' do
    qstr = "ALTER TABLE `#{params[:table]}` DROP `#{params['column_name']}`"
    query(qstr)
    fields = schema_table(params[:table])
    render fields: fields, query: qstr
  end
  
  get '/' do
    'Hello World'
  end
end