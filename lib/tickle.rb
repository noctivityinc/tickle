#=============================================================================
#
#  Name:       Tickle
#  Author:     Joshua Lippiner
#  Purpose:    Parse natural language into recuring intervals
#
#=============================================================================

$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

require 'chronic'
require 'numerizer/numerizer'

require 'tickle/tickle'

module Tickle
  VERSION = "0.0.1"
  
  def self.debug; false; end
end