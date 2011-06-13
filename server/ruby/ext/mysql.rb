Mysql::Result.class_eval {
  include Enumerable
  
  def fields
    self.fetch_fields.map {|item| item.hash['name'] }
  end
  
  def rows
    rows = []
    self.each_hash do |item|
      item.each_pair {|k,v| v.nil? ? item[k] = '' : nil }
      rows << item
    end
    rows
  end
}
