module Choice
  
  # The parser takes our option definitions and our arguments and produces
  # a hash of values.
  module Parser #:nodoc: all
    
    # What method to call on an object for each given 'cast' value.
    CAST_METHODS = { Integer => :to_i, String => :to_s, Float => :to_f,
                     Symbol => :to_sym }
    
    # Perhaps this method does too much.  It is, however, a parser.
    # You pass it an array of arrays, the first element of each element being
    # the option's name and the second element being a hash of the option's
    # info.  You also pass in your current arguments, so it knows what to
    # check against.
    def self.parse(options, args)
      # Return empty hash if the parsing adventure would be fruitless.
      return {} if options.nil? || !options || args.nil? || !args.is_a?(Array)
      
      # If we are passed an array, make the best of it by converting it
      # to a hash.
      if options.is_a?(Array)
        new_options = {}
        options.each { |o| new_options[o[0]] = o[1] if o.is_a?(Array) }
        options = new_options
      end
      
      # Define local hashes we're going to use.  choices is where we store
      # the actual values we've pulled from the argument list.
      hashes, longs, required, validators, choices = {}, {}, {}, {}, {}

      # We can define these on the fly because they are all so similar.
      params = %w[short cast filter action default valid]
      params.each { |param| hashes["#{param}s"] = {} }

      # Inspect each option and move its info into our local hashes.
      options.each do |name, obj|
        name = name.to_s

        # Only take hashes or hash-like duck objects.
        if obj.respond_to?(:to_h)
          obj = obj.to_h 
        else
          raise HashExpectedForOption
        end

        # Set the local hashes if the value exists on this option object.
        params.each { |param| hashes["#{param}s"][name] = obj[param] if obj[param] }
        
        # If there is a validate statement, save it as a regex.
        # If it's present but can't pull off a to_s (wtf?), raise an error.
        if obj['validate'] && obj['validate'].respond_to?(:to_s)
          validators[name] = Regexp.new(obj['validate'].to_s)
        elsif obj['validate']
          raise ValidateExpectsRegexp
        end
        
        # Parse the long option. If it contains a =, figure out if the 
        # argument is required or optional.  Optional arguments are formed
        # like [=ARG], whereas required are just ARG (in --long=ARG style).
        if obj['long'] && obj['long'] =~ /(=|\[)/
          # Save the separator we used, as we're gonna need it, then split
          sep = $1
          option, *argument = obj['long'].split(sep)

          longs[name] = option

          # Preserve the original argument, as it may contain [ or =,
          # by joining with the character we split on.  Add a [ in front if
          # we split on that.
          argument = (sep == '[' ? '[' : '') << Array(argument).join(sep)

          required[name] = true unless argument =~ /^\[(.+)\]$/
        elsif obj['long']
          # We can't have a long as a switch when valid is set -- die.
          raise ArgumentRequiredWithValid if obj['valid']

          # Set without any checking if it's just --long
          longs[name] = obj['long']
        end

        # If we were given a list of valid arguments with 'valid,' this option
        # is definitely required.
        required[name] = true if obj['valid']
      end

      # Go through the arguments and try to figure out whom they belong to
      # at this point.
      args.each_with_index do |arg, i|
        if hashes['shorts'].value?(arg)
          # Set the value to the next element in the args array since
          # this is a short.
          value = args[i+1]

          # If the next element doesn't exist or starts with a -, make this
          # value true.
          value = true if !value || value =~ /^-/

          # Add this value to the choices hash with the key of the option's
          # name.
          choices[hashes['shorts'].index(arg)] = value

        elsif arg =~ /=/ && longs.value?((longed = arg.split('=')).first)
          # If we get a long with a = in it, grab it and the argument
          # passed to it.
          choices[longs.index(longed.shift)] = longed * '='

        elsif longs.value?(arg)
          # If we get a long with no =, just set it to true.
          choices[longs.index(arg)] = true

        else
          # If we're here, we have no idea what the passed argument is.  Die.
          raise UnknownOption if arg =~ /^-/

        end
      end

      # Okay, we got all the choices.  Now go through and run any filters or
      # whatever on them.
      choices.each do |name, value|
        # Check to make sure we have all the required arguments.
        raise ArgumentRequired if required[name] && value === true

        # Validate the argument if we need to.
        raise ArgumentValidationFails if validators[name] && validators[name] !~ value

        # Make sure the argument is valid
        raise InvalidArgument if hashes['valids'][name] && !hashes['valids'][name].include?(value)
        
        # Cast the argument using the method defined in the constant hash.
        value = value.send(CAST_METHODS[hashes['casts'][name]]) if hashes['casts'].include?(name)
        
        # Run the value through a filter and re-set it with the return.
        value = hashes['filters'][name].call(value) if hashes['filters'].include?(name)

        # Run an action block if there is one associated.
        hashes['actions'][name].call(value) if hashes['actions'].include?(name)
        
        # Now that we've done all that, re-set the element of the choice hash
        # with the (potentially) new value.
        choices[name] = value
      end
      
      # Home stretch.  Go through all the defaults defined and if a choice
      # does not exist in our choices hash, set its value to the requested
      # default.
      hashes['defaults'].each do |name, value|
        choices[name] = value unless choices[name]
      end
      
      # Return the choices hash.
      choices
    end
    
    # All the possible exceptions this module can raise.
    class ParseError < Exception; end
    class HashExpectedForOption < Exception; end
    class UnknownOption < ParseError; end      
    class ArgumentRequired < ParseError; end
    class ValidateExpectsRegexp < ParseError; end
    class ArgumentValidationFails < ParseError; end
    class InvalidArgument < ParseError; end
    class ArgumentRequiredWithValid < ParseError; end
  end
end
