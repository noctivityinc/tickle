#=============================================================================
#
#  Name:       Tickle
#  Author:     Joshua Lippiner
#  Purpose:    Parse natural language into recuring intervals
#
#=============================================================================

$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

require 'date'
require 'time'
require 'chronic'

require 'tickle/tickle'
require 'tickle/handler'
require 'tickle/repeater'

module Tickle
  VERSION = "0.0.3"
  
  def self.debug; false; end
  
  def self.dwrite(msg)
    puts msg if Tickle.debug
  end
end

class Date 
   def days_in_month 
     d,m,y = mday,month,year 
     d += 1 while Date.valid_civil?(y,m,d) 
     d - 1 
   end 
end

class Array
  def same?(y)
    self.sort == y.sort
  end
end