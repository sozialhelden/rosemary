class Hash
  def symbolize_keys!
    self.each do |k,v|
      self[k.to_sym] = v
      self.delete(k)
    end
  end

  def stringify_keys!
    temp_hash = {}
    self.each do |k,v|
      temp_hash[k.to_s] = self.delete(k)
    end
    temp_hash.each do |k,v|
      self[k] = v
    end
  end
end