require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'time'
require 'test/unit'

class TestParsing < Test::Unit::TestCase

  def setup
  end

  def test_parse_best_guess_simple
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
    parse_now('the 3rd of February')
    parse_now('the 3rd of February 2012')
    parse_now('the 3rd of Feb, 2012')

    parse_now('the 4th of the month')
    parse_now('the 10th of the month')
    parse_now('the tenth of the month')

    parse_now('the first of the month')
    parse_now('the thirtieth')
    parse_now('the fifth')

    parse_now('the 3rd Sunday of May')
    parse_now('the 3rd Sunday of the month')

    parse_now('the 23rd of June')
    parse_now('the twenty third of June')
    parse_now('the thirty first of August')

    parse_now('the twenty first')
    parse_now('the twenty first of the month')
  end

  def test_parse_best_guess_complex
    puts "Time.now"
    p Time.now

    parse_now('starting today and ending one week from now') # => demonstrates leaving out the actual time period and implying it as daily

    # parse_now('starting Monday repeat every month')
    # parse_now('starting May 13th repeat every week')
    # parse_now('starting May 13th repeat every other day')
    # 
    # parse_now('every week starts this wednesday')
    # parse_now('every other day starts the 1st May')
    # parse_now('every other day starting May 6')
    # parse_now('every week starting this wednesday')
    # parse_now('every other day starting the 1st May')
    # 
    # parse_now("every other day starting May 1st #{Date.today.year + 1}")
    # parse_now('every other week starting this Sunday')
    # 
    # parse_now('every week starting this wednesday until June 5th')
    # parse_now('every week starting this wednesday ends June 5th')
    # parse_now('every week starting this wednesday ending June 5th')

  end

  def test_tickle_args
    parse_now('May 1st, 2011', {:next_only => true})

    start_date = Date.civil(Date.today.year, Date.today.month, Date.today.day + 10)
    parse_now('every 3 days', {:start => start_date})
    parse_now('every 3 weeks', {:start => start_date})
    parse_now('every 3 months', {:start => start_date})
    parse_now('every 3 years', {:start => start_date})

    end_date = Date.civil(Date.today.year, Date.today.month+5, Date.today.day)
    parse_now('every 3 days', {:start => start_date, :until  => end_date})
    parse_now('every 3 weeks', {:start => start_date, :until  => end_date})
    parse_now('every 3 months', {:until => end_date})
  end

  def test_argument_validation
    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse("may 27", :today => 'something odd')
    end

    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse("may 27", :foo => :bar)
    end

    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse(nil)
    end

    assert_raise(Tickle::InvalidDateExpression) do
      past_date = Date.civil(Date.today.year, Date.today.month, Date.today.day - 1)
      time = Tickle.parse("every other day", {:start => past_date})
    end

    assert_raise(Tickle::InvalidDateExpression) do
      start_date = Date.civil(Date.today.year, Date.today.month, Date.today.day + 10)
      end_date = Date.civil(Date.today.year, Date.today.month, Date.today.day + 5)
      time = Tickle.parse("every other day", :start => start_date, :until => end_date)
    end

    assert_raise(Tickle::InvalidDateExpression) do
      end_date = Date.civil(Date.today.year, Date.today.month+2, Date.today.day)
      parse_now('every 3 months', {:until => end_date})
    end
  end

  private
  def parse_now(string, options={})
    out = Tickle.parse(string, {}.merge(options))
    puts (options.empty? ?  ("Tickle.parse('#{string}')  #=> #{out}") : ("Tickle.parse('#{string}, #{options}')  #=> #{out}"))
    p '--' if Tickle.debug
    out
  end
end
