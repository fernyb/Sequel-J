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
end