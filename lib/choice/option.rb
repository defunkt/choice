module Choice

  # The Option class parses and stores all the information about a specific
  # option.
  class Option #:nodoc: all
    # You can instantiate an option on its own or by passing it a name and
    # a block.  If you give it a block, it will eval() the block and set itself
    # up nicely.

    def initialize(required = false, &block)
      @choices = {}

      # If we got a block, eval it and set everything up.
      instance_eval(&block) if block_given?

      # Is this option required?

      @choices['required'] = required
    end

    def method_missing(method, *args, &block)
      # Mask NoMethodError
      # TODO: Remove this, if it doesn't make sense.
      raise ParseError, "I don't know `#{method}'"
    end

    def required
      @choices['required']
    end

    def short(value=nil)
      value_setter('short', value)
      @choices['short']
    end

    def short?
      @choices['short']
    end

    def long(value=nil)
      value_setter('long', value)
      @choices['long']
    end

    def long?
      @choices['long']
    end

    def default(value=nil)
      value_setter('default', value)
      @choices['default']
    end

    def default?
      @choices['default']
    end

    def cast(value=nil)
      value_setter('cast', value)
      @choices['cast']
    end

    def cast?
      @choices['cast']
    end

    def valid(value=nil)
      value_setter('valid', value)
      @choices['valid']
    end

    def valid?
      @choices['valid']
    end

    # TODO: Should this be split into two different validate methods?
    def validate(value=nil, &block)
      if !value.nil?
        value_setter('validate', value)
      elsif !block.nil?
        block_setter('validate', &block)
      end
      @choices['validate']
    end

    def validate?
      @choices['validate']
    end

    def action(&block)
      block_setter('action', &block)
      @choices['action']
    end

    def action?
      @choices['action']
    end

    def filter(&block)
      block_setter('filter', &block)
      @choices['filter']
    end

    def filter?
      @choices['filter']
    end

    # The desc method is slightly special: it stores itself as an array and
    # each subsequent call adds to that array, rather than overwriting it.
    # This is so we can do multi-line descriptions easily.
    def desc(string = nil)
      return @choices['desc'] if string.nil?

      @choices['desc'] ||= []
      @choices['desc'].push(string)
    end

    # Simple, desc question method.
    def desc?() !!@choices['desc'] end

    # Returns Option converted to an array.
    def to_a
      [
        required,
        short,
        long,
        desc,
        default,
        filter,
        action,
        cast,
        valid,
        validate
      ].compact
    end

    # Returns Option converted to a hash.
    def to_h
      @choices.dup
    end

    private

    def value_setter(name, value)
      if !value.nil?
        @choices[name] = value
      end
    end

    def block_setter(name, &block)
      if block
        @choices[name] = block
      end
    end

    # In case someone tries to use a method we don't know about in their
    # option block.
    class ParseError < Exception; end
  end
end
