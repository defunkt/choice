module Choice

  # The Option class parses and stores all the information about a specific
  # option.
  class Option #:nodoc: all
    # You can instantiate an option on its own or by passing it a name and
    # a block.  If you give it a block, it will eval() the block and set itself
    # up nicely.
    def initialize(options = {}, &block)
      # Here we store the definitions this option contains, to make to_a and
      # to_h easier.
      @choices = []

      # If we got a block, eval it and set everything up.
      instance_eval(&block) if block_given?

      # Is this option required?
      @required = options[:required] || false
      @choices << 'required'
    end

    def method_missing(method, *args, &block)
      # Mask NoMethodError
      # TODO: Remove this, if it doesn't make sense.
      raise ParseError, "I don't know `#{method}'"
    end

    def short(value=nil)
      value_setter('short', value)
      @short
    end

    def short?
      @short
    end

    def long(value=nil)
      value_setter('long', value)
      @long
    end

    def long?
      @long
    end

    def default(value=nil)
      value_setter('default', value)
      @default
    end

    def default?
      @default
    end

    def cast(value=nil)
      value_setter('cast', value)
      @cast
    end

    def cast?
      @cast
    end

    def valid(value=nil)
      value_setter('valid', value)
      @valid
    end

    def valid?
      @valid
    end

    # TODO: Should this be split into two different validate methods?
    def validate(value=nil, &block)
      if !value.nil?
        value_setter('validate', value)
      elsif !block.nil?
        block_setter('validate', &block)
      end
      @validate
    end

    def validate?
      @validate
    end

    def action(&block)
      block_setter('action', &block)
      @action
    end

    def action?
      @action
    end

    def filter(&block)
      block_setter('filter', &block)
      @filter
    end

    def filter?
      @filter
    end

    # The desc method is slightly special: it stores itself as an array and
    # each subsequent call adds to that array, rather than overwriting it.
    # This is so we can do multi-line descriptions easily.
    def desc(string = nil)
      return @desc if string.nil?

      @desc ||= []
      @desc.push(string)

      # Only add to @choices array if it's not already present.
      @choices << 'desc' unless @choices.index('desc')
    end

    # Simple, desc question method.
    def desc?() !!@desc end

    # Returns Option converted to an array.
    def to_a
      @choices.inject([]) do |array, choice|
        return array unless @choices.include? choice
        array + [instance_variable_get("@#{choice}")]
      end
    end

    # Returns Option converted to a hash.
    def to_h
      @choices.inject({}) do |hash, choice|
        return hash unless @choices.include? choice
        hash.merge choice => instance_variable_get("@#{choice}")
      end
    end

    private

    def value_setter(name, value)
      unless value.nil?
        instance_variable_set("@#{name}", value)
        @choices << name unless @choices.include?(name)
      end
    end

    def block_setter(name, &block)
      if block
        instance_variable_set("@#{name}", block)
        @choices << name unless @choices.include?(name)
      end
    end

    # In case someone tries to use a method we don't know about in their
    # option block.
    class ParseError < Exception; end
  end
end
