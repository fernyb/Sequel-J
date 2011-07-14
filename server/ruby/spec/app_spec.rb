FILE_PATH = File.absolute_path(__FILE__)
DIR_PATH = File.dirname(FILE_PATH)

require "#{DIR_PATH}/spec_helper.rb"

describe "App" do
  def app
    @app ||= App
  end
  
  def json
    @_json ||= JSON.parse(last_response.body)
  end
  
  alias_method :response, :last_response
  
  before :each do
    @mysql = mock("MySQL")
    Mysql.stub(new: @mysql)
  end
    
  after :each do
    @_json = nil
  end
  
  describe '/' do
    it "returns hello world" do
      get '/'
      response.body.should == 'Hello World'
    end
  end
  
  describe '/connect' do
    it 'returns an error message when not sending credentials' do
      Mysql.should_receive(:new).and_raise(Mysql::Error.new('Access denied for user'))
      get '/connect'
      
      json['connected'].should be_false
      json['error'].should =~ /Access denied for user/
      json['path'].should == '/connect'
    end
    
    it 'returns connected true when it connects' do
      Mysql.should_receive(:new).with(*['127.0.0.1', '', '' ,'']).and_return @mysql
      @mysql.should_receive(:query).with("SHOW CHARACTER SET").
      and_return(Struct.new(:rows).new([{'Description' => 'UTF-8 Unicode', 'Charset' => 'utf8'}]))
      
      get '/connect'
      
      json['connected'].should be_true
      json['error'].should == ''
      json['path'].should == '/connect'
      json['character_sets'].first['Description'].should == 'UTF-8 Unicode'
      json['character_sets'].first['Charset'].should == 'utf8'
    end
  end
  
  describe '/databases' do
    it 'returns a list of databases' do
      @mysql.should_receive(:list_dbs).and_return ['dbname_one', 'dbname_two']
      get '/databases'
      json['databases'].size.should > 0
      json['error'].should == ''
      json['path'].should == '/databases'
    end
    
    it 'returns an empty list when MySQL throws an error' do
      @mysql.should_receive(:list_dbs).and_raise(Mysql::Error)
      get '/databases'
      
      json['databases'].size.should == 0
      json['path'].should == '/databases'
    end
    
    it 'has an error message when MySQL throws an error' do
      @mysql.should_receive(:list_dbs).and_raise(Mysql::Error.new('Error Message...'))
      get '/databases'
      
      json['error'].should == 'Error Message...'
      json['path'].should == '/databases'
    end  
  end
  
  describe '/tables' do
    it 'returns a list of tables' do
      @mysql.should_receive(:list_tables).and_return ['table_name_one', 'table_name_two']
      get '/tables'
      
      json['path'].should == '/tables'
      json['tables'].should include('table_name_one', 'table_name_two')
      json['error'].should == ''
    end
    
    it 'returns an empty list of tables when MySQL throws an error' do
      @mysql.should_receive(:list_tables).and_raise(Mysql::Error.new('Error did not select database'))
      get '/tables'
      
      json['path'].should == '/tables'
      json['error'].should == 'Error did not select database'
      json['tables'].size.should == 0
    end
  end
  
  describe '/columns/:table' do
    it 'returns column names' do
      @mysql.should_receive(:query).with('SHOW COLUMNS FROM `table_name`').and_return([
        ['field', 'type', 'null', 'key', 'default', 'extra']
      ])
      get '/columns/table_name'
      
      json['path'].should == '/columns/table_name'
      json['error'].should == ''
      json['columns'].size.should == 1
      
      field = json['columns'].first
      field['field'].should   == 'field'
      field['type'].should    == 'type'
      field['null'].should    == 'null'
      field['key'].should     == 'key'
      field['default'].should == 'default'
      field['extra'].should   == 'extra'
    end
    
    it 'returns error message when Mysql throws an error' do
      @mysql.should_receive(:query).and_raise(Mysql::Error.new('There was an error...'))
      get '/columns/table_name'
      
      json['path'].should == '/columns/table_name'
      json['columns'].size.should == 0
      json['error'].should == 'There was an error...'
    end
  end
  
  describe '/rows/:table' do
    before do
      result = [{'total_rows' => '2'}]
      @mysql.should_receive(:query).with("SELECT COUNT(*) AS total_rows FROM `table_name`").and_return(result)
    end
    
    it 'returns rows for table_name' do
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `table_name`").and_return([
        ['id', 'type', 'null', 'key', 'default', 'extra'],
        ['user_id', 'type', 'null', 'key', 'default', 'extra'],
        ['name', 'type', 'null', 'key', 'default', 'extra'],
        ['description', 'type', 'null', 'key', 'default', 'extra'],
        ['latitude', 'type', 'null', 'key', 'default', 'extra'],
        ['longitude', 'type', 'null', 'key', 'default', 'extra'],
        ['created_at', 'type', 'null', 'key', 'default', 'extra'],
        ['updated_at', 'type', 'null', 'key', 'default', 'extra'],
        ['test', 'type', 'null', 'key', 'default', 'extra']
      ])
    
      @mysql.should_receive(:query).with("SELECT * FROM `table_name` LIMIT 0,100").and_return [
        ["00000000077", "39", "Redford, MI", nil, "42.4326", "-83.306", "2009-05-31 05:10:35", "2009-05-31 05:10:35", nil],
        ["00000000038", "39", "Livonia, MI", nil, "42.3692", "-83.3683", "2009-05-24 07:58:17", "2009-05-24 07:58:17", nil],
        ["00000000009", "1", "Los Angeles, CA", nil, "34.0489", "-118.252", "2009-04-08 03:34:00", "2009-04-08 03:34:00", nil],
        ["00000000006", "1", "Whittier, CA", nil, "33.9999", "-118.067", "2009-04-08 03:33:49", "2009-04-08 03:33:49", nil]
      ]
    
      get '/rows/table_name'
      
      json['path'].should == '/rows/table_name'
      json['error'].should == ''
      json['rows'].size.should > 0
      
      row = json['rows'].first
      row['id'].should          == '00000000077'
      row['user_id'].should     == '39'
      row['name'].should        == 'Redford, MI'
      row['description'].should == 'NULL'
      row['latitude'].should    == '42.4326'
      row['longitude'].should   == '-83.306'
      row['created_at'].should  == '2009-05-31 05:10:35'
      row['updated_at'].should  == '2009-05-31 05:10:35'
      row['test'].should        == 'NULL'
      json['total_rows'].should  == '2'
    end
    
    it "returns an error message when mysql gives an error" do
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `table_name`").and_return []
      @mysql.should_receive(:query).with("SELECT * FROM `table_name` LIMIT 0,100").and_raise(Mysql::Error.new("There is an error..."))
      get '/rows/table_name'
      
      json['path'].should == '/rows/table_name'
      json['error'].should == "There is an error..."
      json['rows'].size.should == 0
    end

    it "does not load TEXT and BLOB field" do
      query = {
        defer_blob_text: 'YES'
      }

      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `table_name`").and_return([
        ['id', 'type', 'null', 'key', 'default', 'extra'],
        ['user_id', 'type', 'null', 'key', 'default', 'extra'],
        ['name', 'TEXT', 'null', 'key', 'default', 'extra'],
        ['description', 'BLOB', 'null', 'key', 'default', 'extra']
      ])

      @mysql.should_receive(:query).
        with("SELECT id,user_id,NULL,NULL FROM `table_name` LIMIT 0,100").
        and_return([
          ['1', '100', nil, nil]
        ])

      get "/rows/table_name?#{query.to_query_string}"
      json['rows'][0]['name'].should == '(not loaded)'
      json['rows'][0]['description'].should == '(not loaded)'
    end
  end

  describe '/schema/:table' do
    describe "GET" do
      it 'returns the schema for table_name' do
        @mysql.should_receive(:query).with("SHOW COLUMNS FROM `table_name`").and_return([
          ["id", "int(11) unsigned zerofill", "NO", "PRI", nil, "auto_increment"],
          ["user_id", "int(11)", "YES", "MUL", nil, ""],
          ["name", "varchar(255)", "YES", "", nil, ""],
          ["description", "text", "YES", "", nil, ""],
          ["latitude", "float", "YES", "MUL", nil, ""],
          ["longitude", "float", "YES", "MUL", nil, ""],
          ["created_at", "datetime", "YES", "MUL", nil, ""],
          ["updated_at", "datetime", "YES", "", nil, ""],
          ["test", "varchar(255)", "YES", "MUL", nil, ""]
        ])
      
        get '/schema/table_name'
      
        json['path'].should == '/schema/table_name'
        json['error'].should == ''
        json['fields'].size == 9
        json['fields'].first.keys.should include('Field', 'Type', 'Length', 'Unsigned', 'Zerofill', 'Binary', 'Allow Null', 'Key', 'Default')
      end
    
      it 'returns error message for Mysql Error' do
        @mysql.should_receive(:query).and_raise(Mysql::Error.new('There is an error.'))
        get '/schema/table_name'
      
        json['path'].should == '/schema/table_name'
        json['error'].should == 'There is an error.'
        json['fields'].size == 0
      end
    end
    
    describe "POST" do
      before do
        @query = {
          port:     '3306',
          database: 'skatr_development',
          host:     'localhost',
          password: 'password',
          username: 'root',
          field:    'id',
          type:     'int',
          length:   '11',
          unsigned: 'NO',
          name:     'unsigned',
          extra:    'auto_increment',
          null:     'NO'
        }
      end
      
      it "updates the id field usigned attribute when unsigned is NO" do
        @mysql.should_receive(:query).with("ALTER TABLE `checkins` CHANGE `id` `id` int(11) NOT NULL auto_increment").and_return nil
        @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, "auto_increment"],
            ["user_id", "int(11)", "YES", "MUL", nil, ""],
            ["name", "varchar(255)", "YES", "", nil, ""],
            ["description", "text", "YES", "", nil, ""],
            ["latitude", "float", "YES", "MUL", nil, ""],
            ["longitude", "float", "YES", "MUL", nil, ""],
            ["created_at", "datetime", "YES", "MUL", nil, ""],
            ["updated_at", "datetime", "YES", "", nil, ""],
            ["test", "varchar(255)", "YES", "MUL", nil, ""]
          ])
          
        post "/schema/checkins?#{@query.to_query_string}"
      
        json['path'].should == '/schema/checkins'
        json['error'].should == ''
        json['fields'].size.should == 9
        json['fields'].first['Field'].should == 'id'
        json['fields'].first['Unsigned'].should be_false
      end

      it "updates the id field usigned attribute when unsigned is YES" do
        @query[:name] = 'unsigned'
        @query[:unsigned] = 'YES'
        
        @mysql.should_receive(:query).with("ALTER TABLE `checkins` CHANGE `id` `id` int(11) UNSIGNED NOT NULL auto_increment").and_return nil
        @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([
            ["id", "int(11) unsigned zerofill", "NO", "PRI", nil, "auto_increment"],
            ["user_id", "int(11)", "YES", "MUL", nil, ""],
            ["name", "varchar(255)", "YES", "", nil, ""],
            ["description", "text", "YES", "", nil, ""],
            ["latitude", "float", "YES", "MUL", nil, ""],
            ["longitude", "float", "YES", "MUL", nil, ""],
            ["created_at", "datetime", "YES", "MUL", nil, ""],
            ["updated_at", "datetime", "YES", "", nil, ""],
            ["test", "varchar(255)", "YES", "MUL", nil, ""]
          ])
          
        post "/schema/checkins?#{@query.to_query_string}"
      
        json['path'].should == '/schema/checkins'
        json['error'].should == ''
        json['fields'].size.should == 9
        json['fields'].first['Field'].should == 'id'
        json['fields'].first['Unsigned'].should be_true
      end

      it "updates the extra field, auto_increment" do
        @query[:name] = ''
        @query[:unsigned] = 'YES'
        @query[:extra] = 'auto_increment'
        
        @mysql.should_receive(:query).with("ALTER TABLE `checkins` CHANGE `id` `id` int(11) UNSIGNED NOT NULL auto_increment").and_return nil
        @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([
            ["id", "int(11) unsigned zerofill", "NO", "PRI", nil, "auto_increment"],
            ["user_id", "int(11)", "YES", "MUL", nil, ""],
            ["name", "varchar(255)", "YES", "", nil, ""],
            ["description", "text", "YES", "", nil, ""],
            ["latitude", "float", "YES", "MUL", nil, ""],
            ["longitude", "float", "YES", "MUL", nil, ""],
            ["created_at", "datetime", "YES", "MUL", nil, ""],
            ["updated_at", "datetime", "YES", "", nil, ""],
            ["test", "varchar(255)", "YES", "MUL", nil, ""]
          ])
          
        post "/schema/checkins?#{@query.to_query_string}"
      
        json['path'].should == '/schema/checkins'
        json['error'].should == ''
        json['fields'].size.should == 9
        json['fields'].first['Field'].should == 'id'
        json['fields'].first['Extra'].should.should == 'auto_increment'
      end  

      it "updates the extra field, to be none and should not be unsigned" do
        @query[:name] = ''
        @query[:unsigned] = 'NO'
        @query[:extra] = 'none'
        
        @mysql.should_receive(:query).with("ALTER TABLE `checkins` CHANGE `id` `id` int(11) NOT NULL").and_return nil
        @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["user_id", "int(11)", "YES", "MUL", nil, ""],
            ["name", "varchar(255)", "YES", "", nil, ""],
            ["description", "text", "YES", "", nil, ""],
            ["latitude", "float", "YES", "MUL", nil, ""],
            ["longitude", "float", "YES", "MUL", nil, ""],
            ["created_at", "datetime", "YES", "MUL", nil, ""],
            ["updated_at", "datetime", "YES", "", nil, ""],
            ["test", "varchar(255)", "YES", "MUL", nil, ""]
          ])
          
        post "/schema/checkins?#{@query.to_query_string}"
      
        json['path'].should == '/schema/checkins'
        json['error'].should == ''
        json['fields'].size.should == 9
        json['fields'].first['Field'].should == 'id'
        json['fields'].first['Extra'].should.should == ''
        json['fields'].first['Unsigned'].should be_false
      end

      it "can handle MySQL errors" do
        @query[:name] = ''
        @query[:unsigned] = 'NO'
        @query[:extra] = 'none'
        
        @mysql.should_receive(:query).with("ALTER TABLE `checkins` CHANGE `id` `id` int(11) NOT NULL").and_raise(Mysql::Error.new("There is an error..."))

        post "/schema/checkins?#{@query.to_query_string}"
      
        json['path'].should == '/schema/checkins'
        json['error'].should == 'There is an error...'
        json['fields'].size.should == 0
      end                 
    end
  end

  describe '/indexes/:table' do
    it 'returns indexes for table_name' do
      @mysql.should_receive(:query).with("SHOW INDEX FROM `table_name`").and_return([
        ["checkins", "0", "PRIMARY", "1", "id", "A", "85", nil, nil, "", "BTREE", ""],
        ["checkins", "1", "index_checkins_on_id", "1", "id", "A", "85", nil, nil, "", "BTREE", ""],
        ["checkins", "1", "index_checkins_on_user_id", "1", "user_id", "A", "8", nil, nil, "YES", "BTREE", ""],
        ["checkins", "1", "index_checkins_on_created_at", "1", "created_at", "A", "85", nil, nil, "YES", "BTREE", ""],
        ["checkins", "1", "index_checkins_on_latitude", "1", "latitude", "A", "85", nil, nil, "YES", "BTREE", ""],
        ["checkins", "1", "index_checkins_on_longitude", "1", "longitude", "A", "85", nil, nil, "YES", "BTREE", ""],
        ["checkins", "1", "test_index", "1", "test", "A", "2", nil, nil, "YES", "BTREE", ""]
      ])
      
      get '/indexes/table_name'
      
      json['path'].should == '/indexes/table_name'
      json['error'].should == ''
      json['indexes'].size.should == 7
      json['indexes'].first.keys.should include('Non_unique', 'Key_name', 'Seq_in_index', 'Column_name', 'Collation', 'Cardinality')
      json['indexes'].first.keys.should include('Sub_part', 'Packed', 'Null', 'Index_type', 'Comment')
    end
    
    it 'returns error message when Mysql gives an error' do
      @mysql.should_receive(:query).with("SHOW INDEX FROM `table_name`").and_raise(Mysql::Error.new('There is an error...'))
      get '/indexes/table_name'
      
      json['path'].should == '/indexes/table_name'
      json['indexes'].size.should == 0
      json['error'].should == 'There is an error...'
    end
  end
  
  describe '/relations/:table' do
    it 'returns relations for table checkins' do
      sql_code = File.open("#{DIR_PATH}/fixture/checkins.sql") {|f| f.read }
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `checkins`").and_return(['checkins', sql_code])
      get '/relations/checkins'
      
      json['path'].should == '/relations/checkins'
      json['error'].should == ''
      json['relations'].size.should == 4
      json['relations'].each do |r|
        r.keys.should include('name', 'foreign_key', 'reference_key', 'on_delete', 'on_update', 'reference_table')
      end
    end
    
    it 'returns error message when Mysql throws an error' do
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `checkins`").and_raise(Mysql::Error.new('There is an error'))
      get '/relations/checkins'
      
      json['path'].should == '/relations/checkins'
      json['error'].should == 'There is an error'
      json['relations'].size.should == 0
    end
  end
  
  describe '/show_create_table/:table' do
    it 'returns sql create table code' do
      sql_code = File.open("#{DIR_PATH}/fixture/checkins.sql") {|f| f.read }
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `checkins`").and_return(['checkins', sql_code])
      get '/show_create_table/checkins'
      
      json['sql'].should == sql_code
      json['path'].should == '/show_create_table/checkins'
      json['error'].should == ''
    end
    
    it 'returns error message when Mysql throws and error' do
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `checkins`").and_raise(Mysql::Error.new('There is a error'))
      get '/show_create_table/checkins'
      
      json['path'].should == '/show_create_table/checkins'
      json['error'].should == 'There is a error'
      json['sql'].should == ''
    end
  end
  
  describe '/table_info/:table' do
    it 'returns table info' do
      @mysql.should_receive(:query).with("SHOW TABLE STATUS LIKE 'checkins'").and_return([[
        "checkins", "InnoDB", "10", "Compact", "85", "192", "16384", "0", "98304", "428867584", "86", "2011-06-02 15:09:52", nil, nil, "utf8_general_ci", nil, "", ""
      ]])
      @mysql.should_receive(:query).with("SELECT Engine, Support FROM information_schema.engines WHERE support IN ('DEFAULT', 'YES')").and_return([
        ["InnoDB", "YES"],
        ["MRG_MYISAM", "YES"],
        ["BLACKHOLE", "YES"],
        ["CSV", "YES"],
        ["MEMORY", "YES"],
        ["ARCHIVE", "YES"],
        ["MyISAM", "DEFAULT"]
      ])
      @mysql.should_receive(:query).with("SELECT * FROM information_schema.character_sets ORDER BY character_set_name ASC").and_return([
        ["ucs2", "ucs2_general_ci", "UCS-2 Unicode", "2"],
        ["ujis", "ujis_japanese_ci", "EUC-JP Japanese", "3"],
        ["utf8", "utf8_general_ci", "UTF-8 Unicode", "3"]
      ])
      @mysql.should_receive(:query).
      with("SELECT * FROM information_schema.collations WHERE character_set_name = 'utf8' ORDER BY 'collation_name' ASC").
      and_return([
       ["utf8_general_ci", "utf8", "33", "Yes", "Yes", "1"],
       ["utf8_bin", "utf8", "83", "", "Yes", "1"],
       ["utf8_unicode_ci", "utf8", "192", "", "Yes", "8"],
       ["utf8_icelandic_ci", "utf8", "193", "", "Yes", "8"],
       ["utf8_latvian_ci", "utf8", "194", "", "Yes", "8"],
       ["utf8_romanian_ci", "utf8", "195", "", "Yes", "8"]
      ])
      sql_code = File.open("#{DIR_PATH}/fixture/checkins.sql") {|f| f.read }
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `checkins`").and_return(['checkins', sql_code])
      
      get '/table_info/checkins'
      
      json['path'].should == '/table_info/checkins'
      json['error'].should == ''
      json['status'].should == {"name"=>"checkins", 
        "engine"=>"InnoDB", 
        "version"=>"10", 
        "row_format"=>"Compact", 
        "rows"=>"85", 
        "avg_row_length"=>"192", 
        "data_length"=>"16384", 
        "max_data_length"=>"0", 
        "index_length"=>"98304", 
        "data_free"=>"428867584", 
        "auto_increment"=>"86", 
        "create_time"=>"2011-06-02 15:09:52", 
        "update_time"=>"", 
        "check_time"=>"", 
        "collation"=>"utf8_general_ci", 
        "checksum"=>"", 
        "create_options"=>"", 
        "comment"=>""}
      
      json['engines'].should == ["InnoDB", "MRG_MYISAM", "BLACKHOLE", "CSV", "MEMORY", "ARCHIVE", "MyISAM"]
      json['encodings'].should == [{"collation_name"=>"ucs2", "collate_set_name"=>"ucs2_general_ci", "description"=>"UCS-2 Unicode"}, 
                                   {"collation_name"=>"ujis", "collate_set_name"=>"ujis_japanese_ci", "description"=>"EUC-JP Japanese"}, 
                                   {"collation_name"=>"utf8", "collate_set_name"=>"utf8_general_ci", "description"=>"UTF-8 Unicode"}]
      
      json['collations'].should == [{"collation_name"=>"utf8_general_ci", "character_set_name"=>"utf8", "id"=>"33"}, 
                                    {"collation_name"=>"utf8_bin", "character_set_name"=>"utf8", "id"=>"83"}, 
                                    {"collation_name"=>"utf8_unicode_ci", "character_set_name"=>"utf8", "id"=>"192"}, 
                                    {"collation_name"=>"utf8_icelandic_ci", "character_set_name"=>"utf8", "id"=>"193"}, 
                                    {"collation_name"=>"utf8_latvian_ci", "character_set_name"=>"utf8", "id"=>"194"}, 
                                    {"collation_name"=>"utf8_romanian_ci", "character_set_name"=>"utf8", "id"=>"195"}]
      
      json['sql'].should == sql_code
    end
    
    it 'returns error message when Mysql throws an error' do
      @mysql.should_receive(:query).with("SHOW TABLE STATUS LIKE 'checkins'").and_raise(Mysql::Error.new('Mysql Error Message'))
      
      sql_code = File.open("#{DIR_PATH}/fixture/checkins.sql") {|f| f.read }
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `checkins`").and_return(['checkins', sql_code])
      
      get '/table_info/checkins'
      
      json['path'].should == '/table_info/checkins'
      json['error'].should == 'Mysql Error Message'
      json['status'].should == ''
      json['engines'].should == ''
      json['encodings'].size.should == 0
      json['collations'].size.should == 0
      json['sql'].should == sql_code
    end
  end
  
  describe '/query' do
    it 'returns results for query' do
      result = mock("Mysql::Result")
      fields = ['user_id', 'name']
      result.stub(fields: fields)
      rows = [{"user_id" => "1","name" => "Whittier, CA"},
              {"user_id" => "1","name" => "Whittier, CA"},
              {"user_id" => "1","name" => "Los Angeles, CA"},
              {"user_id" => "1","name" => "Los Angeles, CA"},
              {"user_id" => "1","name" => "Whittier, CA"}]
             
      result.stub(rows: rows)
      
      @mysql.should_receive(:query).with("select user_id, name from checkins LIMIT 0, 5").and_return(result)
      get '/query?query=select%20user_id,%20name%20from%20checkins%20LIMIT%200,%205'
      
      json['path'].should == '/query'
      json['error'].should == ''
      json['columns'].should == fields
      json['results'].should == rows
    end
    
    it 'returns an error message when Mysql throws an error' do
      @mysql.should_receive(:query).with("select user_id, name from checkins LIMIT 0, 5").and_raise(Mysql::Error.new('There is an error!'))
      get '/query?query=select%20user_id,%20name%20from%20checkins%20LIMIT%200,%205'
      
      json['path'].should == '/query'
      json['error'].should == 'There is an error!'
      json['columns'].size.should == 0
      json['results'].size.should == 0
    end
  end
  
  describe '/api.php' do
    it "will redirect request to the appropiate endpoint" do
      get '/api.php?endpoint=query&query=select%20user_id,%20name%20from%20checkins%20LIMIT%200,%205'
      response.status.should == 307
      response.headers['Location'].should == 'http://example.org/query?query=select%20user_id%2C%20name%20from%20checkins%20LIMIT%200%2C%205'
    end
    
    it "will redirect request to the appropiate endpoint with table name" do
      get '/api.php?endpoint=table_info&table=checkins'
      response.status.should == 307
      response.headers['Location'].should == 'http://example.org/table_info/checkins'  
    end
  end
  
  describe '/updatecolumn/:table' do
    before do
     @query = { 
        port:                '3306',
        database:            'skatr_development',
        host:                'localhost',
        password:            'password',
        username:            'root',
        after_column_name:   'random_id',
        column_name:         'hello',
        column_type:         'int',
        column_length:       '11',
        column_unsigned:     'NO',
        column_zerofill:     'NO',
        column_binary:       'NO',
        column_default:      'NULL',
        column_extra:        '',
        previous_value:      '',
        update_column_name:  ''
      }
    end
    
    it 'will add new column' do
      @mysql.should_receive(:query).with("ALTER TABLE `checkins` ADD `hello` int NULL DEFAULT NULL AFTER `random_id`")
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(2).times.and_return []
      post "/updatecolumn/checkins?#{@query.to_query_string}"
    end
    
    it 'rename column name' do
      @query[:previous_value] = 'hello'
      @query[:column_name] = 'new_hello_name'
      
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` CHANGE `hello` `new_hello_name` int(11) NULL DEFAULT NULL AFTER `random_id`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(2).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"  
    end

    it 'update column type' do
      @query[:previous_value] = 'text'
      @query[:update_column_name] = 'Type'
      @query[:column_name] = 'hello'
      @query[:column_type] = 'varchar'
      @query[:column_length] = ''
      
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` CHANGE `hello` `hello` varchar(255) NULL DEFAULT NULL AFTER `random_id`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"  
    end  
    
    it "update column length" do
      @query.merge!({
        after_column_name: 'name',
        previous_value: '',
        update_column_name: 'Length',
        column_name: 'description',
        column_type: 'text',
        column_length: '255'
      })
      
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` CHANGE `description` `description` text(255) NULL DEFAULT NULL AFTER `name`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"
    end
    
    it "update column Field" do
      @query.merge!({
        previous_value: 'description',
        update_column_name: 'Field',
        column_name: 'description2',
        column_type: 'text',
        column_length: '',
      })
      
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` CHANGE `description` `description2` text NULL DEFAULT NULL AFTER `random_id`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"
    end
    
    it "update column default with type int" do
      @query.merge!({
        after_column_name: 'updated_at',
        previous_value: 'NULL',
        update_column_name: 'Default',
        column_name: 'user_id',
        column_type: 'int',
        column_length: '11',
        column_default: '0',
      })
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` CHANGE `user_id` `user_id` int(11) NULL DEFAULT '0' AFTER `updated_at`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"
    end

    it "update column default with type varchar" do
      @query.merge!({
        after_column_name: 'updated_at',
        previous_value: 'NULL',
        update_column_name: 'Default',
        column_name: 'user_id',
        column_type: 'varchar',
        column_length: '255',
        column_default: 'hello'
      })
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` CHANGE `user_id` `user_id` varchar(255) NULL DEFAULT 'hello' AFTER `updated_at`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"
    end
    
    it "creates new column when it doesn't exist"  do
      @query.merge!({
        after_column_name: 'hello3Copy',
        previous_value: '',
        update_column_name: 'Field',
        column_name: 'helloNOW',
        column_type: 'int',
        column_length: '11',
        column_default: '0',
        action_name: 'duplicate'
      })
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` ADD `helloNOW` int(11) NULL DEFAULT '0' AFTER `hello3Copy`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}" 
    end
    
    it "creates coloumn when action_name is add" do
      @query.merge!({
        after_column_name: 'updated_at',
        previous_value: '',
        update_column_name: 'Field',
        column_name: 'Untitled',
        column_type: 'int',
        column_length: '11',
        column_default: 'NULL',
        column_extra: '',
        action_name: 'add'
      })
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` ADD `Untitled` int(11) NULL DEFAULT NULL AFTER `updated_at`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}" 
    end
    
    it "duplicate column when action_name is duplicate with type text" do
      @query.merge!({
        after_column_name: 'updated_at',
        previous_value: '',
        update_column_name: 'Field',
        column_name: 'Untitled',
        column_type: 'text',
        column_length: '',
        column_default: 'NULL',
        column_extra: '',
        action_name: 'duplicate'
      })
    
      @mysql.should_receive(:query).
      with("ALTER TABLE `checkins` ADD `Untitled` text NULL DEFAULT NULL AFTER `updated_at`")
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
            ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
            ["hello", "int(11)", "YES", "MUL", nil, ""]
      ])
      post "/updatecolumn/checkins?#{@query.to_query_string}"
    end  
  end
  
  describe '/add_index/:table' do
    before :each do
      @query = {
        type: 'INDEX',
        name: 'udid_idx',
        index_column: 'udid'
      }
    end
    
    it 'adds an index of type INDEX' do
      @mysql.should_receive(:query).with("ALTER TABLE `checkins` ADD INDEX `udid_idx` (`udid`)")
      @mysql.should_receive(:query).with("SHOW INDEX FROM `checkins`").and_return []
      post "/add_index/checkins?#{@query.to_query_string}"
    end
    
    it 'adds an index of type FULLTEXT' do
      @query[:type] = 'fulltext'
      @query.merge!({
        type: 'fulltext',
        name: 'untitled_fulltext_idx',
        index_column: 'Untitled'
      })
      
      @mysql.should_receive(:query).with("ALTER TABLE `checkins` ADD FULLTEXT `untitled_fulltext_idx` (`Untitled`)")
      @mysql.should_receive(:query).with("SHOW INDEX FROM `checkins`").and_return []
      post "/add_index/checkins?#{@query.to_query_string}"
    end
  end
  
  describe '/drop_index/:table' do
    before :each do
      @query = {
        name: 'udid_idx',
        index_column: 'udid'
      }
    end
    
    it 'drops index of type INDEX' do
      @mysql.should_receive(:query).with("ALTER TABLE `people` DROP INDEX `udid_idx`")
      @mysql.should_receive(:query).with("SHOW INDEX FROM `people`").and_return []
      post "/remove_index/people?#{@query.to_query_string}"
    end  
  end
  
  describe '/add_table/:table' do
    before do
      @query = {
        table_encoding: 'utf8',
        table_type: 'MyISAM'
      }
    end
    
    it 'creates new table' do
      @mysql.should_receive(:query).
      with("CREATE TABLE `test_five` (id INT NOT NULL) DEFAULT CHARACTER SET `utf8` ENGINE = `MyISAM`")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      
      post "/add_table/test_five?#{@query.to_query_string}"
      json['path'].should == '/add_table/test_five'
      json['tables'].should include('t1', 't2', 't3')
    end
    
    it 'creates new table with defaults' do
      @query.merge!({
        table_encoding: '',
        table_type: ''
      })
      
      @mysql.should_receive(:query).
      with("CREATE TABLE `test_five` (id INT NOT NULL)")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      
      post "/add_table/test_five?#{@query.to_query_string}"
      json['path'].should == '/add_table/test_five'
      json['tables'].should include('t1', 't2', 't3')  
    end
    
    it 'creates new table with encoding defaults' do
      @query.merge!({
        table_encoding: '',
        table_type: 'InnoDB'
      })
      
      @mysql.should_receive(:query).
      with("CREATE TABLE `test_five` (id INT NOT NULL) ENGINE = `InnoDB`")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      
      post "/add_table/test_five?#{@query.to_query_string}"
      json['path'].should == '/add_table/test_five'
      json['tables'].should include('t1', 't2', 't3')  
    end

    it 'creates new table with type defaults' do
      @query.merge!({
        table_encoding: 'utf8',
        table_type: ''
      })
      
      @mysql.should_receive(:query).
      with("CREATE TABLE `test_five` (id INT NOT NULL) DEFAULT CHARACTER SET `utf8`")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      
      post "/add_table/test_five?#{@query.to_query_string}"
      json['path'].should == '/add_table/test_five'
      json['tables'].should include('t1', 't2', 't3')  
    end    
  end
  
  describe '/remove_table/:table' do
    it 'can drop table' do
      @mysql.should_receive(:query).with("DROP TABLE `test_one`")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
    
      post "/remove_table/test_one"
      json['path'].should == '/remove_table/test_one'
    end
  end
  
  describe '/truncate_table/:table' do
    it 'can truncate table' do
      @mysql.should_receive(:query).with("TRUNCATE TABLE `test_one`")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
    
      post "/truncate_table/test_one"
      json['path'].should == '/truncate_table/test_one'
    end
  end
  
  describe '/duplicate_table/:table' do
    before do
      @query = {
        duplicate_content: 'NO',
        name: 'names_copy'
      }
      
      @sql_code = File.open("#{DIR_PATH}/fixture/names.sql") {|f| f.read }
    end
    
    it 'can duplicate a table' do
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `names`").and_return(['names', @sql_code])
      @mysql.should_receive(:query).with("CREATE TABLE `names_copy` (\n  `Number` int(11) NOT NULL AUTO_INCREMENT,\n  `Gender` varchar(6) NOT NULL,\n  `GivenName` varchar(50) NOT NULL,\n  `MiddleInitial` varchar(2) NOT NULL,\n  `Surname` varchar(50) NOT NULL,\n  `StreetAddress` varchar(150) NOT NULL,\n  `City` varchar(200) NOT NULL,\n  `State` varchar(100) NOT NULL,\n  `ZipCode` mediumint(9) NOT NULL,\n  `Country` varchar(3) NOT NULL,\n  `EmailAddress` varchar(255) NOT NULL,\n  `TelephoneNumber` varchar(15) NOT NULL,\n  `MothersMaiden` varchar(100) NOT NULL,\n  `Birthday` varchar(15) NOT NULL,\n  `CCType` varchar(100) NOT NULL,\n  `CCNumber` bigint(20) NOT NULL,\n  `CVV2` smallint(6) NOT NULL,\n  `CCExpires` varchar(12) NOT NULL,\n  `NationalID` varchar(255) NOT NULL,\n  `description` text,\n  PRIMARY KEY (`Number`),\n  KEY `Gender` (`Gender`),\n  KEY `City` (`City`),\n  KEY `State` (`State`),\n  KEY `ZipCode` (`ZipCode`),\n  KEY `Country` (`Country`),\n  KEY `EmailAddress` (`EmailAddress`),\n  KEY `CCNumber` (`CCNumber`)\n) ENGINE=MyISAM  DEFAULT CHARSET=latin1")
      
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      post "/duplicate_table/names?#{@query.to_query_string}"
      
      json['sql'].should match(/CREATE TABLE `names_copy`/)
      json['sql'].should_not match(/AUTO_INCREMENT=\d+/)
    end
    
    it 'can duplicate a table and content' do
      @query.merge!({ duplicate_content: 'YES' })
      @mysql.should_receive(:query).with("SHOW CREATE TABLE `names`").and_return(['names', @sql_code])
      @mysql.should_receive(:query).with("CREATE TABLE `names_copy` (\n  `Number` int(11) NOT NULL AUTO_INCREMENT,\n  `Gender` varchar(6) NOT NULL,\n  `GivenName` varchar(50) NOT NULL,\n  `MiddleInitial` varchar(2) NOT NULL,\n  `Surname` varchar(50) NOT NULL,\n  `StreetAddress` varchar(150) NOT NULL,\n  `City` varchar(200) NOT NULL,\n  `State` varchar(100) NOT NULL,\n  `ZipCode` mediumint(9) NOT NULL,\n  `Country` varchar(3) NOT NULL,\n  `EmailAddress` varchar(255) NOT NULL,\n  `TelephoneNumber` varchar(15) NOT NULL,\n  `MothersMaiden` varchar(100) NOT NULL,\n  `Birthday` varchar(15) NOT NULL,\n  `CCType` varchar(100) NOT NULL,\n  `CCNumber` bigint(20) NOT NULL,\n  `CVV2` smallint(6) NOT NULL,\n  `CCExpires` varchar(12) NOT NULL,\n  `NationalID` varchar(255) NOT NULL,\n  `description` text,\n  PRIMARY KEY (`Number`),\n  KEY `Gender` (`Gender`),\n  KEY `City` (`City`),\n  KEY `State` (`State`),\n  KEY `ZipCode` (`ZipCode`),\n  KEY `Country` (`Country`),\n  KEY `EmailAddress` (`EmailAddress`),\n  KEY `CCNumber` (`CCNumber`)\n) ENGINE=MyISAM AUTO_INCREMENT=2000 DEFAULT CHARSET=latin1")
      @mysql.should_receive(:query).with("INSERT INTO `names_copy` SELECT * FROM `names`")
      
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      post "/duplicate_table/names?#{@query.to_query_string}"
      
      json['sql'].should match(/CREATE TABLE `names_copy`/)
      json['sql'].should match(/AUTO_INCREMENT=\d+/)
    end
  end
  
  describe '/rename_table/:table' do
    before do
      @query = {
        name: 'new_table_name'
      }
    end
    
    it 'can rename table' do
      @mysql.should_receive(:query).with("RENAME TABLE `names` TO `new_table_name`")
      @mysql.should_receive(:list_tables).and_return ['t1', 't2', 't3']
      post "/rename_table/names?#{@query.to_query_string}"
    end
  end

  describe '/update_table_row/:table' do
    before do
      @query = {
        field_name: 'id',
        field_value: '101',
        offset: '0',
        limit: '100'
      }
      
      @where_fields = {
        id: '4',
        name: 'fernyb',
        description: 'hello'
      }
      
      result = [{'total_rows' => '2'}]
      @mysql.should_receive(:query).with("SELECT COUNT(*) AS total_rows FROM `checkins`").and_return(result)
    end
    
    after :each do
      json['total_rows'].should == '2'
    end
    
    it 'can update a row' do
      update_query = "UPDATE `checkins` SET `id` = '101' WHERE `id` = '4' AND `name` = 'fernyb' AND `description` = 'hello' LIMIT 1"
      @mysql.should_receive(:query).with(update_query)
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([])
      @mysql.should_receive(:query).with("SELECT * FROM `checkins` LIMIT 0,100").and_return([
        {'id' => '2', 'name' => 'query'}
      ])
      
      where_query = @where_fields.to_query_string_with_key('where_fields')
    
      post "/update_table_row/checkins?#{@query.to_query_string}&#{where_query}"
      
      json['path'].should == '/update_table_row/checkins'
      json['query'].should == update_query
    end
    
    it 'can update a row when a field is NULL' do
      @where_fields.merge!(description: 'NULL')
      
      update_query = "UPDATE `checkins` SET `id` = '101' WHERE `id` = '4' AND `name` = 'fernyb' AND `description` IS NULL LIMIT 1"
      @mysql.should_receive(:query).with(update_query)
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([])
      @mysql.should_receive(:query).with("SELECT * FROM `checkins` LIMIT 0,100").and_return([
        {'id' => '2', 'name' => 'query'}
      ])
      
      where_query = @where_fields.to_query_string_with_key('where_fields')
    
      post "/update_table_row/checkins?#{@query.to_query_string}&#{where_query}"
      
      json['path'].should == '/update_table_row/checkins'
      json['query'].should == update_query
    end
    
    it 'can add new row with NULL fields & CURRENT_TIMESTAMP' do
      @query.merge!({
        field_name:  '',
        field_value: '',
        add_row:     'YES'
      })
      
      @where_fields.merge!({
        id:          'NULL',
        name:        'NULL',
        description: 'NULL',
        created_at:  'NULL',
        timestamp:   'CURRENT_TIMESTAMP'
      })
      
      query_string = "INSERT INTO `checkins` (`id`,`name`,`description`,`created_at`,`timestamp`) VALUES (NULL,NULL,NULL,NULL,CURRENT_TIMESTAMP)"
      @mysql.should_receive(:query).with(query_string)
    
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([])
      @mysql.should_receive(:query).with("SELECT * FROM `checkins` LIMIT 0,100").and_return([
        {'id' => '2', 'name' => 'query'}
      ])
      
      where_query = @where_fields.to_query_string_with_key('where_fields')
    
      post "/update_table_row/checkins?#{@query.to_query_string}&#{where_query}"
      
      json['path'].should == '/update_table_row/checkins'
      json['query'].should == query_string
    end

    it 'can add new row' do
      @query.merge!({
        field_name:  '',
        field_value: '',
        add_row:     'YES'
      })
      
      @where_fields.merge!({
        id:          '1',
        name:        'fernyb',
        description: 'Today is a great day!',
        created_at:  'CURRENT_TIMESTAMP',
        timestamp:   'CURRENT_TIMESTAMP'
      })
      
      query_string = "INSERT INTO `checkins` (`id`,`name`,`description`,`created_at`,`timestamp`) VALUES ('1','fernyb','Today is a great day!',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)"
      @mysql.should_receive(:query).with(query_string)
    
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([])
      @mysql.should_receive(:query).with("SELECT * FROM `checkins` LIMIT 0,100").and_return([
        {'id' => '2', 'name' => 'query'}
      ])
      
      where_query = @where_fields.to_query_string_with_key('where_fields')
    
      post "/update_table_row/checkins?#{@query.to_query_string}&#{where_query}"
      
      json['path'].should == '/update_table_row/checkins'
      json['query'].should == query_string
    end
    
    it 'can update row when description is blank' do
      @where_fields.merge!(description: '')
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([
        ["id", "int(11) zerofill", "NO", "PRI", nil, ""],
        ["name", "varchar(255)", "YES", "MUL", nil, ""],
        ["description", "text", "", "", nil, ""]
      ])
      
      update_query = "UPDATE `checkins` SET `id` = '101' WHERE `id` = '4' AND `name` = 'fernyb' AND `description` = '' LIMIT 1"
      @mysql.should_receive(:query).with(update_query)
      
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").at_least(1).times.and_return([])
      @mysql.should_receive(:query).with("SELECT * FROM `checkins` LIMIT 0,100").and_return([
        {'id' => '2', 'name' => 'query'}
      ])
      
      where_query = @where_fields.to_query_string_with_key('where_fields')
    
      post "/update_table_row/checkins?#{@query.to_query_string}&#{where_query}"
      
      json['path'].should == '/update_table_row/checkins'
      json['query'].should == update_query      
    end
  end 
  
  describe '/remove_table_row/:table' do
    before do
      @where_fields = {
        id: '4',
        name: 'fernyb',
        description: 'hello'
      }
      
      result = [{'total_rows' => '2'}]
      @mysql.should_receive(:query).with("SELECT COUNT(*) AS total_rows FROM `checkins`").and_return(result)
    end
    
    it 'can remove row' do
      where_query = @where_fields.to_query_string_with_key('where_fields')
      
      @mysql.should_receive(:query).with("DELETE FROM `checkins` WHERE `id` = '4' AND `name` = 'fernyb' AND `description` = 'hello' LIMIT 1")
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `checkins`").and_return([])
      @mysql.should_receive(:query).with("SELECT * FROM `checkins` LIMIT 0,100").and_return([])
      
      post "/remove_table_row/checkins?#{where_query}"
      json['total_rows'].should == '2'
    end
  end 
end
