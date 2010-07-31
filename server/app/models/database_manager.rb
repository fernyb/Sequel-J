class DatabaseManager
  @@credentials = {}
  
  def self.credentials(params)
    @@credentials = {
      :adapter  => "mysql",
      :username => params[:username],
      :password => params[:password],
      :host     => params[:host],
      :database => params[:database],
      :port     => params[:port]
    }
    self
  end
  
  class << self
    def connect
      @@mysql ||= Mysql.new(@@credentials[:host], @@credentials[:username], @@credentials[:password], @@credentials[:database])
    end
  
    def tables
      results = connect.query("SHOW TABLES");
      tables = []
      results.each{|t| tables << t }
      tables.flatten!
      results.free
      tables
    end
  end
end