require 'choice/option'
require 'choice/parser'
require 'choice/writer'
require 'choice/lazyhash'

module Choice
  class <<self
    def options(&block)
      @@args    ||= false
      @@banner  ||= false
      @@header  ||= Array.new
      @@options ||= Array.new
      @@footer  ||= Array.new
      self.args = @@args || ARGV
      instance_eval(&block)
      parse
    end
  
    def choices
      @@choices
    end
  
    def option(opt, &block)
      @@options << [opt.to_s, Option.new(&block)]
    end
    
    def separator(str)
      @@options << str
    end
    
    def banner(str = nil)
      return @@banner if str.nil?
      @@banner = str
    end
    
    def header(str = nil)
      return @@header if str.nil?
      @@header << str
    end
    
    def footer(str = nil)
      return @@footer if str.nil?
      @@footer << str
    end
    
    def parse #:nodoc:
      return unless @@options.size > 0
      if @@args.include?('--help')
        self.help
      else
        begin
          @@choices = LazyHash.new(Parser.parse(@@options, @@args))
        rescue Choice::Parser::UnknownArgument, Choice::Parser::ArgumentRequired
          self.help
        end
      end
    end
    
    def parsed? #:nodoc:
      @@choices ||= false
    end
    
    def help #:nodoc:
      Writer.help( { :banner => @@banner, :header => @@header, 
                     :options => @@options, :footer => @@footer }, 
                     output_to, exit_on_help?)
    end
    
    def args=(args) #:nodoc:
      @@args = args.dup.map{ |a| a + '' }
      parse if parsed?
    end
  
    def args #:nodoc:
      @@args
    end
    
    def dont_exit_on_help=(val) #:nodoc:
      @@exit = true
    end
    
    def exit_on_help? #:nodoc:
      @@exit rescue false
    end
    
    def output_to(target = nil) #:nodoc:
      @@output_to ||= STDOUT
      return @@output_to if target.nil?
      @@output_to = target
    end
    
    def reset #:nodoc:
      @@args    = false
      @@banner  = false
      @@header  = Array.new
      @@options = Array.new
      @@footer  = Array.new
    end
  end
  
end
