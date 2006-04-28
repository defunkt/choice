#!/usr/bin/env ruby

require 'test/unit'
require 'lib/choice'

class TestWriter < Test::Unit::TestCase
  
  def setup
    Choice.reset
  end
  
  HELP_OUT = ''
  def test_help
    song = Choice::Option.new do
      short '-s'
      long '--song=SONG'
      cast String
      desc 'Your favorite GNR song.'
      desc '(Default: MyMichelle)'
      default 'MyMichelle'
    end
    dude = Choice::Option.new do
      short '-d'
      long '--dude=DUDE'
      cast String
      desc 'Your favorite GNR dude.'
      desc '(Default: Slash)'
      default 'Slash'
    end

    options = [[:song, song], [:dude, dude]]
    args = { :banner => "Welcome to the jungle",
             :header => [""],
             :options => options,
             :footer => ["", "Wake up."] }

    help_string = <<-HELP
Welcome to the jungle

    -s, --song=SONG                  Your favorite GNR song.
                                     (Default: MyMichelle)
    -d, --dude=DUDE                  Your favorite GNR dude.
                                     (Default: Slash)

Wake up.
HELP

    Choice::Writer.help(args, HELP_OUT, true)
    
    assert_equal help_string, HELP_OUT
  end
  
  BANNER_OUT = ''
  def test_banner
    Choice::Writer.help(Hash.new, BANNER_OUT, true)
    
    assert (BANNER_OUT =~ /Usage/)
  end
  
  
end
