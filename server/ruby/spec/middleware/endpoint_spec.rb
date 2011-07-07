FILE_PATH = File.absolute_path(__FILE__)
DIR_PATH = File.dirname(FILE_PATH) + "/.."

require "#{DIR_PATH}/spec_helper.rb"
require "#{DIR_PATH}/../middleware/endpoint.rb"

describe "Endpoint" do
  before do
  @env = {
    "PATH_INFO"=>"/api.php", 
    "QUERY_STRING"=>"endpoint=connect&port=3306&database=&host=localhost&password=&username=root", 
    "REMOTE_ADDR"=>"127.0.0.1", 
    "REMOTE_HOST"=>"localhost", 
    "REQUEST_METHOD"=>"GET", 
    "REQUEST_URI"=>"http://localhost:3000/api.php?endpoint=connect&port=3306&database=&host=localhost&password=&username=root",
    "HTTP_VERSION"=>"HTTP/1.1", 
    "REQUEST_PATH"=>"/api.php",
    "SERVER_NAME"=>"localhost", 
    "SERVER_PORT"=>"3000"
    }
    @app = Endpoint.new nil
  end
  
  it 'translate to correct endpoint' do
    @app.endpoint(@env)
    
    @env['PATH_INFO'].should == '/connect'
    @env['REQUEST_PATH'].should == '/connect'
    @env['QUERY_STRING'].should == 'port=3306&database=&host=localhost&password=&username=root'
    @env['REQUEST_URI'].should == 'http://localhost:3000/connect?port=3306&database=&host=localhost&password=&username=root'
  end
  
  it 'translate to correct endpoint with table name' do
    @env['QUERY_STRING'] = "endpoint=connect&table=checkins&port=3306&database=&host=localhost&password=&username=root"
    @env['REQUEST_URI'] = "http://localhost:3000/api.php?endpoint=connect&table=checkins&port=3306&database=&host=localhost&password=&username=root"
    @app.endpoint(@env)
    
    @env['PATH_INFO'].should == '/connect/checkins'
    @env['REQUEST_PATH'].should == '/connect/checkins'
    @env['QUERY_STRING'].should == 'port=3306&database=&host=localhost&password=&username=root'
    @env['REQUEST_URI'].should == 'http://localhost:3000/connect/checkins?port=3306&database=&host=localhost&password=&username=root'
  end
end