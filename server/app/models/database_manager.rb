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
    
    def databases
      results = connect.query("SHOW DATABASES");
      databases = []
      results.each{|d| databases << d }
      databases.flatten!
      results.free
      databases
    end
    
    def columns(table_name)
      results = connect.query("SHOW COLUMNS FROM `#{table_name}`");

      columns = {
        :columns => {
          :field   => "",
          :type    => "",
          :null    => "",
          :key     => "",
          :default => "",
          :extra   => ""          
        },
        :rows => []
      }
      
      results.each{|d|
        columns[:rows] << {
          :field   => d[0],
          :type    => d[1],
          :null    => d[2],
          :key     => d[3],
          :default => d[4],
          :extra   => d[5]
        }
      }
      
      results.free
      columns
    end  
  end
end