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
      get '/connect'
      
      json['connected'].should be_true
      json['error'].should == ''
      json['path'].should == '/connect'
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
  
  describe '/header_names/:table' do
    it 'returns column for table_name' do
      @mysql.should_receive(:query).with('SHOW COLUMNS FROM `table_name`').and_return [['field', 'type', 'null', 'key', 'default', 'extra']]
      get '/header_names/table_name'

      json['header_names'].size.should == 1
      json['header_names'].first.should == 'field'
      json['error'].should == ''
      json['path'].should == '/header_names/table_name'
    end
    
    it 'returns error message when Mysql throws an error' do
      @mysql.should_receive(:query).and_raise(Mysql::Error.new('There was an error...'))
      get '/header_names/table_name'
      
      json['path'].should == '/header_names/table_name'
      json['error'].should == 'There was an error...'
      json['header_names'].size.should == 0
    end
  end
  
  describe '/rows/:table' do
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
      row['description'].should == ''
      row['latitude'].should    == '42.4326'
      row['longitude'].should   == '-83.306'
      row['created_at'].should  == '2009-05-31 05:10:35'
      row['updated_at'].should  == '2009-05-31 05:10:35'
      row['test'].should        == ''
    end
    
    it "returns an error message when mysql gives an error" do
      @mysql.should_receive(:query).with("SHOW COLUMNS FROM `table_name`").and_return []
      @mysql.should_receive(:query).with("SELECT * FROM `table_name` LIMIT 0,100").and_raise(Mysql::Error.new("There is an error..."))
      get '/rows/table_name'
      
      json['path'].should == '/rows/table_name'
      json['error'].should == "There is an error..."
      json['rows'].size.should == 0
    end
  end

  describe '/schema/:table' do
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
  end
  
  describe '/show_create_table/:table' do
  end
  
  describe '/table_info/:table' do
  end
end