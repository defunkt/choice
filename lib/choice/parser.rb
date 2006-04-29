require 'option'

module Choice
  module Parser
    
    CAST_METHODS = { Integer => :to_i, String => :to_s, Float => :to_s,
                     Symbol => :to_sym }
    
    def self.parse(options, args)
      return {} if options.nil? || !options || args.nil? || !args.is_a?(Array)
      
      if options.is_a?(Array)
        new_options = {}
        options.each { |o| new_options[o[0]] = o[1] if o.is_a?(Array) }
        options = new_options
      end
      
      hashes, longs, required, validators, choices = {}, {}, {}, {}, {}
      params = %w[short cast filter action default]
      params.each { |param| hashes["#{param}s"] = {} }

      options.each do |name, obj|
        name = name.to_s
        obj = obj.to_h

        params.each { |param| hashes["#{param}s"][name] = obj[param] if obj[param] }
        
        if obj['validate'] && obj['validate'].respond_to?(:to_s)
          validators[name] = Regexp.new(obj['validate'].to_s)
        elsif obj['validate']
          raise ValidateExpectsRegexp
        end
        
        if obj['long'] && obj['long'] =~ /=/
          option, argument = obj['long'].split('=')
          longs[name] = option
          required[name] = true unless argument =~ /^\[(.+)\]$/
        elsif obj['long']
          longs[name] = obj['long']
        end
      end

      args.each_with_index do |arg, i|
        if hashes['shorts'].value?(arg)
          value = args[i+1]
          value = true if !value || value =~ /^-/
          choices[hashes['shorts'].index(arg)] = value
        elsif arg =~ /=/ && longs.value?(arg.split('=')[0])
          choices[longs.index(arg.split('=')[0])] = arg.split('=')[1]
        elsif longs.value?(arg)
          choices[longs.index(arg)] = true
        else
          raise UnknownArgument if arg =~ /^-/
        end
      end

      choices.each do |name, value|
        raise ArgumentRequired if required[name] && value === true
        raise ArgumentValidationFails if validators[name] && validators[name] !~ value
        
        choices[name] = value.send(CAST_METHODS[hashes['casts'][name]]) if hashes['casts'].include?(name)
        
        hashes['filters'][name].call(value) if hashes['filters'].include?(name)
        hashes['actions'][name].call(value) if hashes['actions'].include?(name)
      end
      
      hashes['defaults'].each do |name, value|
        choices[name] = value unless choices[name]
      end
      
      choices
    end
    
    class UnknownArgument < Exception; end
    class ValidateExpectsRegexp < Exception; end
    class ArgumentValidationFails < Exception; end
    class ArgumentRequired < Exception; end
  end
end
