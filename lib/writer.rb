module Choice
  module Writer

    def self.help(args, target = STDOUT, dont_exit = false)
      self.target = target
      %w[banner header options footer].each do |meth|
        send(meth, args[meth.to_sym])
      end
      exit unless dont_exit
    end

    class <<self
      private
      
      def banner(banner)
        if banner
          puts banner
        else
          usage
        end
      end
      
      def header(header)
        if header.is_a?(Array) and header.size > 0
          header.each { |line| puts line }
        end
      end

      def options(options)
        return if options.nil? || !options.size
        
        options.each do |name, option|
          if option.is_a?(Choice::Option)
            option_line(option.to_h)          
          else
            puts name
          end
        end
      end
      
      def option_line(option)
        printf '%6s', option['short']
        printf '%-2s', (',' if option['short'] && option['long'])
        printf '%-29s', option['long']

        if option['desc']
          puts option['desc'].shift
          option['desc'].each do |desc| 
            puts ' '*37 + desc
          end
        else
          puts ''
        end

      end
      
      def footer(footer)
        footer.each { |line| puts line } unless footer.nil?
      end
      
      def usage
        puts "Usage: #{program} [options]"
      end

      def program
        if (/(\/|\\)/ =~ $0) then File.basename($0) else $0 end.sub(/\.rb$/,'')
      end

      def target=(target)
        @@target = target
      end
      
      def target
        @@target
      end

      def puts(str)
        print(str + "\n")
      end
      
      def printf(format, *args)
        print(sprintf(format, *args))
      end

      def print(str)
        target << str 
      end
    end
  end
end
