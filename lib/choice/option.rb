module Choice
  class Option    
    CHOICES = %w[short long desc default filter action cast validate]

    def initialize(option = nil, &block)
      @choices = []      
      self.instance_eval(&block) if block_given?      
      defaultize(option) unless option.nil?      
    end
       
    def method_missing(method, *args, &block)
      var = "@#{method.to_s.sub(/\?/,'')}"
      method = method.to_s
      
      raise ParseError, "I don't know '#{method}'" unless CHOICES.include? method.sub(/\?/,'')
      
      return true if method =~ /\?/ and instance_variable_get(var)
      return false if method =~ /\?/
      
      return instance_variable_get(var) unless args[0] || block_given?
      
      instance_variable_set(var, args[0]) if args[0]
      instance_variable_set(var, block) if block_given?
      
      @choices << method if args[0] || block_given?      
    end
    
    def defaultize(option)
      option = option.to_s
      short "-#{option[0..0].downcase}"
      long "--#{option.downcase}=#{option.upcase}"
    end

    def desc(string = nil)
      return @desc if string.nil?
      @desc ||= []
      @desc.push(string)
      @choices << 'desc'
    end
    
    def desc?
      return false if @desc.nil?
      true
    end
    
    def to_a
      array = []
      @choices.each do |choice|
        array << instance_variable_get("@#{choice}") if @choices.include? choice
      end
      array
    end
    
    def to_h
      hash = {}
      @choices.each do |choice|
        hash[choice] = instance_variable_get("@#{choice}") if @choices.include? choice
      end
      hash
    end
    
    class ParseError < Exception; end    
  end
end