class Endpoint
  def initialize(app)
    @app = app
  end
  
  def call(env)
    endpoint(env)
    @app.call(env)
  end
  
  def endpoint(env)
    if env['PATH_INFO'] =~ /\/api\.php/
      params(env)
      endpoint_name = params.delete('endpoint')
      table_name = params.delete('table')
      
      env['PATH_INFO'] = "/#{endpoint_name}"
      env['PATH_INFO'] << "/#{table_name}" if table_name && table_name.size > 1
      
      env['REQUEST_PATH'] = env['PATH_INFO']
      env['QUERY_STRING'] = params.map {|k,v| "#{k}=#{v}" }.join("&")
      
      parts = env['REQUEST_URI'].split("/api\.php", 2) 
      env['REQUEST_URI'] = "#{parts.first}#{env['PATH_INFO']}?#{env['QUERY_STRING']}"
    end
  end
  
  def params(env={})
    @__params = nil if env.keys.size > 0
    unless @__params
      @__params = {}
      env['QUERY_STRING'].to_s.split("&").each {|item| 
        parts = item.split("=")
        k = parts.first
        v = parts.size == 2 ? parts.last : ''
        @__params.merge!({ k.to_s => v.to_s })
      }
    end
    @__params
  end
end