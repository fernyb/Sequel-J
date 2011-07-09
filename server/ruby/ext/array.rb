Array.class_eval {
  def rows
    []
  end
  
  def fields
    []
  end
  
  def each_hash(&block)
    self.each do |item|
      block.call(item)
    end
  end
  
  def num_rows
    self.size
  end
}