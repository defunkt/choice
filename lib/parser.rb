require 'lib/option'
require 'lib/lazyhash'

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
      
      shorts, longs, filters, casts, actions, required = {}, {}, {}, {}, {}, {}
      defaults, validators = {}, {}
      choices = LazyHash.new

      options.each do |name, obj|
        name = name.to_s
        hash = obj.to_h
        shorts[name] = hash['short'] if hash['short']
        casts[name] = hash['cast'] if hash['cast']  
        filters[name] = hash['filter'] if hash['filter']
        actions[name] = hash['action'] if hash['action']
        defaults[name] = hash['default'] if hash['default']
        if hash['validate'] && hash['validate'].respond_to?(:to_s)
          validators[name] = Regexp.new(hash['validate'].to_s)
        elsif hash['validate']
          raise ValidateExpectsRegexp
        end
        if hash['long'] && hash['long'] =~ /=/
          option, argument = hash['long'].split('=')
          longs[name] = option
          required[name] = true unless argument =~ /^\[(.+)\]$/
        elsif hash['long']
          longs[name] = hash['long']
        end
      end

      args.each_with_index do |arg, i|
        if shorts.value?(arg)
          value = args[i+1]
          value = true if !value || value =~ /^-/
          choices[shorts.index(arg)] = value
        end
        if arg =~ /=/ && longs.value?(arg.split('=')[0])
          choices[longs.index(arg.split('=')[0])] = arg.split('=')[1]
        elsif longs.value?(arg)
          choices[longs.index(arg)] = true
        end
      end

      choices.each do |name, value|
        raise ArgumentRequired if required[name] && value === true
        raise ArgumentValidationFails if validators[name] && validators[name] !~ value
        choices[name] = value.send(CAST_METHODS[casts[name]]) if casts.include?(name)
        filters[name].call(value) if filters.include?(name)
        actions[name].call(value) if actions.include?(name)
      end
      
      defaults.each do |name, value|
        choices[name] = value unless choices[name]
      end
      
      choices
    end
    
    class ValidateExpectsRegexp < Exception; end
    class ArgumentValidationFails < Exception; end
    class ArgumentRequired < Exception; end
  end
end
