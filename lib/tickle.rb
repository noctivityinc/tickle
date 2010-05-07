#=============================================================================
#
#  Name:       Tickle
#  Author:     Joshua Lippiner
#  Purpose:    Parse natural language into recuring intervals
#
#=============================================================================


$LOAD_PATH.unshift(File.dirname(__FILE__))     # For use/testing when no gem is installed

require 'date'
require 'time'
require 'chronic'

require 'tickle/tickle'
require 'tickle/handler'
require 'tickle/repeater'

module Tickle
  VERSION = "0.1.3"

  def self.debug; false; end

  def self.dwrite(msg)
    puts msg if Tickle.debug
  end

  def self.is_date(str)
    begin
      Date.parse(str.to_s)
      return true
    rescue Exception => e
      return false
    end
  end
end

class Date
  def days_in_month
    d,m,y = mday,month,year
    d += 1 while Date.valid_civil?(y,m,d)
    d - 1
  end
end

class String
  def is_ordinal?
    scanner = %w{first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth twenty thirty thirtieth}
    regex = /\b(\d*)(st|nd|rd|th)\b/
    !(self =~ regex).nil? || scanner.include?(self.downcase)
  end
end

class Array
  def same?(y)
    self.sort == y.sort
  end
end
