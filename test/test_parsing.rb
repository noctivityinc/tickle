require 'helper'
require 'time'
require 'test/unit'

class TestParsing < Test::Unit::TestCase

  def setup

  end

  def test_parse_best_guess
    puts "Time.now"
    p Time.now

    parse_now('each day')
      
      parse_now('every day')
      parse_now('every week')
      parse_now('every Month')
      parse_now('every year')
      
      parse_now('daily')
      parse_now('weekly')
      parse_now('monthly')
      parse_now('yearly')
      
      parse_now('every 3 days')
      parse_now('every 3 weeks')
      parse_now('every 3 months')
      parse_now('every 3 years')
      
      parse_now('every other day')
      parse_now('every other week')
      parse_now('every other month')
      parse_now('every other year')
      parse_now('every other day starting May 1st')
      parse_now('every other week starting this Sunday')
      
      parse_now('every Monday')
      parse_now('every Wednesday')
      parse_now('every Friday')
      
      parse_now('every May')
      parse_now('every june')
      
      parse_now('beginning of the week')
      parse_now('middle of the week')
      parse_now('end of the week')
      
      parse_now('beginning of the month')
      parse_now('middle of the month')
      parse_now('end of the month')
      
      parse_now('beginning of the year')
      parse_now('middle of the year')
      parse_now('end of the year')

      parse_now('the 3rd of May')
      parse_now('the 3rd of February', {:start => Date.new(2010, 03, 01).to_time})
      
      parse_now('the 10th of the month')
      parse_now('the tenth of the month')
      
      parse_now('the first of the month')
      parse_now('the thirtieth')
      parse_now('the fifth', {:start => Date.new(2010, 03, 15)})

    parse_now('the 3rd Sunday of May')
    parse_now('the 3rd Sunday of the month')
  end

  def test_argument_validation
    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse("may 27", :today => 'something odd')
    end

    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse("may 27", :foo => :bar)
    end
  end

  private
  def parse_now(string, options={})
    out = Tickle.parse(string, {}.merge(options))
    puts ("Tickle.parse('#{string}')  #=> #{out}")
    out
  end
end
