require 'lib/option'
require 'lib/parser'
require 'lib/writer'

module Choice
  VERSION = "1.0"
  AUTHOR = "Chris Wanstrath"
  SITE = "http://rubyforge.org/projects/choice/"
  
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
    
    def parse
      return unless @@options.size > 0
      if @@args.include?('--help')
        self.help
      else
        begin
          @@choices = Parser.parse(@@options, @@args) || {}
        rescue Choice::Parser::UnknownArgument
          self.help
        end
      end
    end
    
    def parsed?
      @@choices ||= false
    end
    
    def help
      Writer.help( { :banner => @@banner, :header => @@header, 
                     :options => @@options, :footer => @@footer }, 
                     output_to, exit_on_help?)
    end
    
    def args=(args)
      @@args = args.dup.map{ |a| a + '' }
      parse if parsed?
    end
  
    def args
      @@args
    end
    
    def dont_exit_on_help=(val)
      @@exit = true
    end
    
    def exit_on_help?
      @@exit rescue false
    end
    
    def output_to(target = nil)
      @@output_to ||= STDOUT
      return @@output_to if target.nil?
      @@output_to = target
    end
    
    def reset
      @@args    = false
      @@banner  = false
      @@header  = Array.new
      @@options = Array.new
      @@footer  = Array.new
    end
  end
  
end