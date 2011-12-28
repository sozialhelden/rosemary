class Hash
  def symbolize_keys!
    self.each do |k,v|
      self[k.to_sym] = v
      self.delete(k)
    end
  end

  def stringify_keys!
    self.each do |k,v|
      self[k.to_s] = self.delete(k)

    end
  end
end