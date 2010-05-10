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

module Tickle #:nodoc:
  VERSION = "0.1.7"

  def self.debug=(val); @debug = val; end

  def self.dwrite(msg, line_feed=nil)
    (line_feed ? p(">> #{msg}") : puts(">> #{msg}")) if @debug
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

class Date #:nodoc:
  # returns the days in the sending month
  def days_in_month
    d,m,y = mday,month,year
    d += 1 while Date.valid_civil?(y,m,d)
    d - 1
  end

  def bump(attr, amount=nil)
    amount ||= 1
    case attr
    when :day then
      Date.civil(self.year, self.month, self.day + amount)
    when :wday then
      amount = Date::ABBR_DAYNAMES.index(amount) if amount.is_a?(String)
      raise Exception, "specified day of week invalid.  Use #{Date::ABBR_DAYNAMES}" unless amount
      diff = (amount > self.wday) ? (amount - self.wday) : (7 - (self.wday - amount))
      Date.civil(self.year, self.month, self.day + diff)
    when :week then
      Date.civil(self.year, self.month, self.day + (7*amount))
    when :month then
      Date.civil(self.year, self.month+amount, self.day)
    when :year then
      Date.civil(self.year + amount, self.month, self.day)
    else
            raise Exception, "type \"#{attr}\" not supported."
    end
  end
end

class Time #:nodoc:
  def bump(attr, amount=nil)
    amount ||= 1
    case attr
    when :sec then
      Time.local(self.year, self.month, self.day, self.hour, self.min, self.sec + amount)
    when :min then
      Time.local(self.year, self.month, self.day, self.hour, self.min + amount, self.sec)
    when :hour then
      Time.local(self.year, self.month, self.day, self.hour + amount, self.min, self.sec)
    when :day then
      Time.local(self.year, self.month, self.day + amount, self.hour, self.min, self.sec)
    when :wday then
      amount = Time::RFC2822_DAY_NAME.index(amount) if amount.is_a?(String)
      raise Exception, "specified day of week invalid.  Use #{Time::RFC2822_DAY_NAME}" unless amount
      diff = (amount > self.wday) ? (amount - self.wday) : (7 - (self.wday - amount))
      Time.local(self.year, self.month, self.day + diff, self.hour, self.min, self.sec)
    when :week then
      Time.local(self.year, self.month, self.day + (amount * 7), self.hour, self.min, self.sec)
    when :month then
      Time.local(self.year, self.month + amount, self.day, self.hour, self.min, self.sec)
    when :year then
      Time.local(self.year + amount, self.month, self.day, self.hour, self.min, self.sec)
    else
      raise Exception, "type \"#{attr}\" not supported."
    end
  end
end

class String #:nodoc:
  # returns true if the sending string is a text or numeric ordinal (e.g. first or 1st)
  def is_ordinal?
    scanner = %w{first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth twenty thirty thirtieth}
    regex = /\b(\d*)(st|nd|rd|th)\b/
    !(self =~ regex).nil? || scanner.include?(self.downcase)
  end

  def ordinal_as_number
    return self unless self.is_ordinal?
    scanner = {/first/ => '1st',
      /second/ => '2nd',
      /third/ => '3rd',
      /fourth/ => '4th',
      /fifth/ => '5th',
      /sixth/ => '6th',
      /seventh/ => '7th',
      /eighth/ => '8th',
      /ninth/ => '9th',
      /tenth/ => '10th',
      /eleventh/ => '11th',
      /twelfth/ => '12th',
      /thirteenth/ => '13th',
      /fourteenth/ => '14th',
      /fifteenth/ => '15th',
      /sixteenth/ => '16th',
      /seventeenth/ => '17th',
      /eighteenth/ => '18th',
      /nineteenth/ => '19th',
      /twentieth/ => '20th',
      /thirtieth/ => '30th',
    }
    result = self
    scanner.keys.each {|scanner_item| result = scanner[scanner_item] if scanner_item =~ self}
    return result.gsub(/\b(\d*)(st|nd|rd|th)\b/, '\1')
  end
end

class Array #:nodoc:
  # compares two arrays to determine if they both contain the same elements
  def same?(y)
    self.sort == y.sort
  end
end
