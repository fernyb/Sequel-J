FILE_PATH = File.absolute_path(__FILE__)
DIR_PATH = File.dirname(FILE_PATH)

require "#{DIR_PATH}/spec_helper.rb"

describe "App" do
  def app
    @app ||= App
  end
  
  it "should respond to /" do
    get '/'
    last_response.body.should == 'Hello World'
  end
  
  describe '/connect' do
    it 'returns an error message when not sending credentials' do
      get '/connect'
      body = JSON.parse(last_response.body)
      
      body['connected'].should be_false
      body['error'].should =~ /Access denied for user/
      body['path'].should == '/connect'
    end
  end
end