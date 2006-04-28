module Choice
  class LazyHash < Hash
    alias_method :old_store, :store
    alias_method :old_fetch, :fetch
    
    def store(key, value)
      self[key] = value
    end
    
    def fetch(key)
      self[key]
    end

    def []=(key, value)
      key = key.to_s if key.is_a? Symbol
      self.old_store(key, value)
    end
    
    def [](key)
      key = key.to_s if key.is_a? Symbol
      self.old_fetch(key) rescue return nil
    end
    
  end
end