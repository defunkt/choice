module Choice

  # The Option class parses and stores all the information about a specific
  # option.
  class Option #:nodoc: all
    # You can instantiate an option on its own or by passing it a name and
    # a block.  If you give it a block, it will eval() the block and set itself
    # up nicely.
    def initialize(required = false, &block)
      # If we got a block, eval it and set everything up.
      instance_eval(&block) if block_given?

      # Is this option required?
      @required = required
    end

    attr_reader :required

    def method_missing(method, *args, &block)
      # Mask NoMethodError
      # TODO: Remove this, if it doesn't make sense.
      raise ParseError, "I don't know `#{method}'"
    end

    def short(value=nil)
      @short ||= value
    end

    def short?
      @short
    end

    def long(value=nil)
      @long ||= value
    end

    def long?
      @long
    end

    def default(value=nil)
      @default ||= value
    end

    def default?
      @default
    end

    def cast(value=nil)
      @cast ||= value
    end

    def cast?
      @cast
    end

    def valid(value=nil)
      @valid ||= value
    end

    def valid?
      @valid
    end

    # TODO: Should this be split into two different validate methods?
    def validate(value=nil, &block)
      @validate ||= if !value.nil?
                      value
                    elsif !block.nil?
                      block
                    end
    end

    def validate?
      @validate
    end

    def action(&block)
      @action ||= block
    end

    def action?
      @action
    end

    def filter(&block)
      @filter ||= block
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
    end

    # Simple, desc question method.
    def desc?
      @desc
    end

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
      {
        "required" => required,
        "short" => short,
        "long" => long,
        "desc" => desc,
        "default" => default,
        "filter" => filter,
        "action" => action,
        "cast" => cast,
        "valid" => valid,
        "validate" => validate
      }.reject {|k, v| v.nil? }
    end

    # In case someone tries to use a method we don't know about in their
    # option block.
    class ParseError < Exception; end
  end
end
