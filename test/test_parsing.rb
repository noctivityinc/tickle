require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'time'
require 'test/unit'

class TestParsing < Test::Unit::TestCase

  def setup
    Tickle.debug = (ARGV.detect {|a| a == '--d'})
    @verbose = (ARGV.detect {|a| a == '--v'})

    puts "Time.now"
    p Time.now

    @date = Date.today
  end

  def test_parse_best_guess_simple
    start = Date.new(2020, 04, 01)

    assert_date_match(@date.bump(:day, 1), 'each day')
    assert_date_match(@date.bump(:day, 1), 'every day')
    assert_date_match(@date.bump(:week, 1), 'every week')
    assert_date_match(@date.bump(:month, 1), 'every month')
    assert_date_match(@date.bump(:year, 1), 'every year')

    assert_date_match(@date.bump(:day, 1), 'daily')
    assert_date_match(@date.bump(:week, 1) , 'weekly')
    assert_date_match(@date.bump(:month, 1) , 'monthly')
    assert_date_match(@date.bump(:year, 1) , 'yearly')

    assert_date_match(@date.bump(:day, 3), 'every 3 days')
    assert_date_match(@date.bump(:week, 3), 'every 3 weeks')
    assert_date_match(@date.bump(:month, 3), 'every 3 months')
    assert_date_match(@date.bump(:year, 3), 'every 3 years')

    assert_date_match(@date.bump(:day, 2), 'every other day')
    assert_date_match(@date.bump(:week, 2), 'every other week')
    assert_date_match(@date.bump(:month, 2), 'every other month')
    assert_date_match(@date.bump(:year, 2), 'every other year')

    assert_date_match(@date.bump(:wday, 'Mon'), 'every Monday')
    assert_date_match(@date.bump(:wday, 'Wed'), 'every Wednesday')
    assert_date_match(@date.bump(:wday, 'Fri'), 'every Friday')

    assert_date_match(Date.new(2021, 2, 1), 'every February', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 5, 1), 'every May', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 6, 1), 'every june', {:start => start, :now => start})

    assert_date_match(@date.bump(:wday, 'Sun'), 'beginning of the week')
    assert_date_match(@date.bump(:wday, 'Wed'), 'middle of the week')
    assert_date_match(@date.bump(:wday, 'Sat'), 'end of the week')

    assert_date_match(Date.new(2020, 05, 01), 'beginning of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 15), 'middle of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 30), 'end of the month', {:start => start, :now => start})

    assert_date_match(Date.new(2021, 01, 01), 'beginning of the year', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 06, 15), 'middle of the year', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 12, 31), 'end of the year', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 03), 'the 3rd of May', {:start => start, :now => start})
    assert_date_match(Date.new(2021, 02, 03), 'the 3rd of February', {:start => start, :now => start})
    assert_date_match(Date.new(2022, 02, 03), 'the 3rd of February 2022', {:start => start, :now => start})
    assert_date_match(Date.new(2022, 02, 03), 'the 3rd of Feb, 2022', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 04, 04), 'the 4th of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 10), 'the 10th of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 10), 'the tenth of the month', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 01), 'first', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 01), 'the first of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 30), 'the thirtieth', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 05), 'the fifth', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 01), 'the 1st Wednesday of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 05, 17), 'the 3rd Sunday of May', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 19), 'the 3rd Sunday of the month', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 06, 23), 'the 23rd of June', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 06, 23), 'the twenty third of June', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 07, 31), 'the thirty first of July', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 04, 21), 'the twenty first', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 21), 'the twenty first of the month', {:start => start, :now => start})
  end

  def test_parse_best_guess_complex
    start = Date.new(2020, 04, 01)

    assert_tickle_match(@date.bump(:day, 1), @date, @date.bump(:week, 1), 'day', 'starting today and ending one week from now') if Time.now.hour < 21 # => demonstrates leaving out the actual time period and implying it as daily
    assert_tickle_match(@date.bump(:day, 1), @date.bump(:day, 1), @date.bump(:week, 1), 'day','starting tomorrow and ending one week from now') # => demonstrates leaving out the actual time period and implying it as daily.

    assert_tickle_match(@date.bump(:wday, 'Mon'), @date.bump(:wday, 'Mon'), nil, 'month', 'starting Monday repeat every month')
    
    year = @date >= Date.new(@date.year, 5, 13) ? @date.bump(:year,1) : @date.year
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'week', 'starting May 13th repeat every week')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'starting May 13th repeat every other day')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starts May 13th')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starts May 13')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starting May 13th')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starting May 13')

    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), nil, 'week', 'every week starts this wednesday')
    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), nil, 'week', 'every week starting this wednesday')

    assert_tickle_match(Date.new(2021, 05, 01), Date.new(2021, 05, 01), nil, 'other day', "every other day starting May 1st #{start.bump(:year, 1).year}")
    assert_tickle_match(Date.new(2021, 05, 01), Date.new(2021, 05, 01), nil, 'other day',  "every other day starting May 1 #{start.bump(:year, 1).year}")
    assert_tickle_match(@date.bump(:wday, 'Sun'), @date.bump(:wday, 'Sun'),  nil, 'other week',  'every other week starting this Sunday')

    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), Date.new(year, 05, 13), 'week', 'every week starting this wednesday until May 13th')
    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), Date.new(year, 05, 13), 'week', 'every week starting this wednesday ends May 13th')
    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), Date.new(year, 05, 13), 'week', 'every week starting this wednesday ending May 13th')

  end

  def test_tickle_args
    actual_next_only = parse_now('May 1st, 2020', {:next_only => true}).to_date
    assert(Date.new(2020, 05, 01).to_date == actual_next_only, "\"May 1st, 2011\" :next parses to #{actual_next_only} but should be equal to #{Date.new(2020, 05, 01).to_date}")

    start_date = Time.now
    assert_tickle_match(start_date.bump(:day, 3), @date, nil, '3 days', 'every 3 days', {:start => start_date})
    assert_tickle_match(start_date.bump(:week, 3), @date, nil, '3 weeks', 'every 3 weeks', {:start => start_date})
    assert_tickle_match(start_date.bump(:month, 3), @date, nil, '3 months', 'every 3 months', {:start => start_date})
    assert_tickle_match(start_date.bump(:year, 3), @date, nil, '3 years', 'every 3 years', {:start => start_date})

    end_date = Date.civil(Date.today.year, Date.today.month+5, Date.today.day).to_time
    assert_tickle_match(start_date.bump(:day, 3), @date, start_date.bump(:month, 5), '3 days', 'every 3 days', {:start => start_date, :until  => end_date})
    assert_tickle_match(start_date.bump(:week, 3), @date, start_date.bump(:month, 5), '3 weeks', 'every 3 weeks', {:start => start_date, :until  => end_date})
    assert_tickle_match(start_date.bump(:month, 3), @date, start_date.bump(:month, 5), '3 months', 'every 3 months', {:until => end_date})
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
    puts (options.empty? ?  ("Tickle.parse('#{string}')\n\r  #=> #{out}\n\r") : ("Tickle.parse('#{string}', #{options})\n\r  #=> #{out}\n\r")) if @verbose
    out
  end

  def assert_date_match(expected_next, date_expression, options={})
    actual_next = parse_now(date_expression, options)[:next].to_date
    assert (expected_next.to_date == actual_next.to_date), "\"#{date_expression}\" parses to #{actual_next} but should be equal to #{expected_next}"
  end

  def assert_tickle_match(expected_next, expected_start, expected_until, expected_expression, date_expression, options={})
    result = parse_now(date_expression, options)
    actual_next = result[:next].to_date
    actual_start = result[:starting].to_date
    actual_until = result[:until].to_date rescue nil
    expected_until = expected_until.to_date rescue nil
    actual_expression = result[:expression]
    
    assert (expected_next.to_date == actual_next.to_date), "\"#{date_expression}\" :next parses to #{actual_next} but should be equal to #{expected_next}"
    assert (expected_start.to_date == actual_start.to_date), "\"#{date_expression}\" :starting parses to #{actual_start} but should be equal to #{expected_start}"
    assert (expected_until == actual_until), "\"#{date_expression}\" :until parses to #{actual_until} but should be equal to #{expected_until}"
    assert (expected_expression == actual_expression), "\"#{date_expression}\" :expression parses to \"#{actual_expression}\" but should be equal to \"#{expected_expression}\""
  end

end
