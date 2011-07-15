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

  def to_copy_query
    row = {}

    self.each_hash do |item|
      item.each_pair {|k,v| 
        row.merge!({ 
          k.to_s => (v.nil? ? 'NULL' : v) 
        })
      }
    end

    table_name = ''
    self.fetch_fields.each do |item|
      if item.is_pri_key?
        table_name = item.table
        row[item.name] = 'NULL'
      end
    end

    keys = row.keys

    insert_keys = keys.map {|k| "`#{k}`" }.join(',')
    insert_values = keys.map {|k| 
      v = row[k]
      v == 'NULL' ? 'NULL' : "'#{v}'"
    }.join(',')

   "INSERT INTO `#{table_name}` (#{insert_keys}) VALUES (#{insert_values})"
  end
}
