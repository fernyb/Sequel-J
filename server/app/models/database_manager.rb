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
  
  def self.connected?
    Mysql.new(@@credentials[:host], @@credentials[:username], @@credentials[:password], @@credentials[:database])
  end
end