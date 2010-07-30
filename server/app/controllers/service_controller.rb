class ServiceController < ApplicationController

  def connect
    db = DatabaseManager.credentials(params)
    response = {}
    begin
      connected = db.try(:connected?) ? "true" : "false"
    rescue Exception => e
      connected = "false"
      response.merge!(:error => e.error)
    end
    
    render :json => response.merge({:connected => connected})
  end
end
