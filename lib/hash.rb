class Hash

  define_method(:symbolize_keys!) do
    self.each do |k,v|
      self[k.to_sym] = v
      self.delete(k)
    end
  end unless method_defined? :symbolize_keys!

  define_method(:stringify_keys!) do
    temp_hash = {}
    self.each do |k,v|
      temp_hash[k.to_s] = self.delete(k)
    end
    temp_hash.each do |k,v|
      self[k] = v
    end
  end unless method_defined? :stringify_keys!
end