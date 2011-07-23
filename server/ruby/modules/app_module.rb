module AppModule
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
  
  def status_table table_name
    results = query "SHOW TABLE STATUS LIKE '#{table_name}'"
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
    status
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
  
  def table_rows table_name
    names = table_columns table_name
    orderby = if params['order_by']
      " ORDER BY `#{params['order_by']}` " << (params['order'] == 'ASC' ? 'ASC ' : 'DESC ')
    else
      ' '
    end

 		column_names = names.collect {|n| n['name'] }
    offset = params['offset'] if params['offset'] != ''
    limit  = params['limit']  if params['limit']  != ''
    offset = '0'   unless offset
    limit  = '100' unless limit
  
    table_column_names = ['*']
    if params['defer_blob_text'] == 'YES' 
      table_column_names = names.map {|n| (n['type'] =~ /BLOB/i || n['type'] =~ /TEXT/i) ? 'NULL' : n['name'] }
    end

    results = query "SELECT #{table_column_names.join(',')} FROM `#{table_name}`#{orderby}LIMIT #{offset},#{limit}"
    rows = results.map {|f|
      f = f.map {|v| v.nil? ? 'NULL' : v }
      if table_column_names.first == '*'
        Hash[*column_names.zip(f).flatten]
      else
        fields = {}
        f.each_with_index do |value, idx|
          name = column_names[idx]
          value = '(not loaded)' if table_column_names[idx] == 'NULL'
          fields.merge!({name.to_s => value.to_s})
        end
        fields
      end
    }
    rows 
  end
  
  def table_total_rows table_name
    result = query "SELECT COUNT(*) AS total_rows FROM `#{table_name}`"
    if result && result.num_rows == 1
      result.each_hash {|item|
        return item['total_rows']
      }
      -1
    else
      -1
    end
  end
  
  def table_columns table_name
    results = query("SHOW COLUMNS FROM `#{table_name}`")
    results.map {|f| 
			{'name' => f[0], 'type' => f[1]}
		}
  end
  
  def sql_for_table table_name
    results = query "SHOW CREATE TABLE `#{table_name}`"
    results = results.collect {|f| f }.flatten
    results.size == 2 ? results.last : ''
  end
  
  def generate_where_for_fields fields
    fields[0].map {|k,v|
      if v.nil? || v == ''
        "`#{k}` = ''"
      elsif v == 'NULL'
        "`#{k}` IS NULL"
      else
        "`#{k}` = #{ (v == 'CURRENT_TIMESTAMP' ? v : "'#{v}'") }"
      end
    }.join(" AND ")
  end

  
  def generate_copy_query result, table_name
    row = {}

    result.each_hash do |item|
      item.each_pair {|k,v| 
        row.merge!({ 
          k.to_s => (v.nil? ? 'NULL' : v) 
        })
      }
    end

    result.fetch_fields.each do |item|
      if item.is_pri_key?
        row[item.name] = 'NULL'
      end
    end

    keys = row.keys

    insert_keys = keys.map {|k| "`#{k}`" }.join(',')
    insert_values = keys.map {|k| 
      v = row[k]
      v == 'NULL' ? 'NULL' : "'#{v}'"
    }.join(',')

   "INSERT INTO `#{table_name}` (#{insert_keys}) VALUES (#{insert_values})"
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

  def relations_for_table table_name
      sql = sql_for_table table_name
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
  end
end
