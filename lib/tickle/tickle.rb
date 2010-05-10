# Copyright (c) 2010 Joshua Lippiner
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Tickle  #:nodoc:
  class << self #:nodoc:
    # == Configuration options
    #
    # * +start+ - start date for future occurrences.  Must be in valid date format.
    # * +until+ - last date to run occurrences until.  Must be in valid date format.
    #
    #  Use by calling Tickle.parse and passing natural language with or without options.
    #
    #  def get_next_occurrence
    #      results = Tickle.parse('every Wednesday starting June 1st until Dec 15th')
    #      return results[:next] if results
    #  end
    #
    def parse(text, specified_options = {})
      # get options and set defaults if necessary.  Ability to set now is mostly for debugging
      default_options = {:start => Time.now, :next_only => false, :until => nil, :now => Time.now}
      options = default_options.merge specified_options

      # ensure an expression was provided
      raise(InvalidArgumentException, 'date expression is required') unless text

      # ensure the specified options are valid
      specified_options.keys.each do |key|
        raise(InvalidArgumentException, "#{key} is not a valid option key.") unless default_options.keys.include?(key)
      end
      raise(InvalidArgumentException, ':start specified is not a valid datetime.') unless  (is_date(specified_options[:start]) || Chronic.parse(specified_options[:start])) if specified_options[:start]

      # check to see if a valid datetime was passed
      return text if text.is_a?(Date) ||  text.is_a?(Time)

      # check to see if this event starts some other time and reset now
      event = scan_expression(text, options)
      
      Tickle.dwrite("start: #{@start}, until: #{@until}, now: #{options[:now].to_date}")

      # => ** this is mostly for testing. Bump by 1 day if today (or in the past for testing)
      raise(InvalidDateExpression, "the start date (#{@start.to_date}) cannot occur in the past for a future event") if @start && @start.to_date < Date.today
      raise(InvalidDateExpression, "the start date (#{@start.to_date}) cannot occur after the end date") if @until && @start.to_date > @until.to_date

      # no need to guess at expression if the start_date is in the future
      best_guess = nil
      if @start.to_date > options[:now].to_date
        best_guess = @start
      else
        # put the text into a normal format to ease scanning using Chronic
        event = pre_filter(event)

        # split into tokens
        @tokens = base_tokenize(event)

        # process each original word for implied word
        post_tokenize

        @tokens.each {|x| Tickle.dwrite("raw: #{x.inspect}")}

        # scan the tokens with each token scanner
        @tokens = Repeater.scan(@tokens)

        # remove all tokens without a type
        @tokens.reject! {|token| token.type.nil? }

        # combine number and ordinals into single number
        combine_multiple_numbers

        @tokens.each {|x| Tickle.dwrite("processed: #{x.inspect}")}

        # if we can't guess it maybe chronic can
        best_guess = (guess || chronic_parse(event))
      end

      raise(InvalidDateExpression, "the next occurrence takes place after the end date specified") if @until && best_guess.to_date > @until.to_date

      if !best_guess
        return nil
      elsif options[:next_only] != true
        return {:next => best_guess.to_time, :expression => event.strip, :starting => @start, :until => @until}
      else
        return best_guess
      end
    end

    # scans the expression for a variety of natural formats, such as 'every thursday starting tomorrow until May 15th
    def scan_expression(text, options)
      starting = ending = nil

      start_every_regex = /^(start(?:s|ing)?)\s(.*)(\s(?:every|each|\bon\b|repeat)(?:s|ing)?)(.*)/i
      every_start_regex = /^(every|each|\bon\b|repeat(?:the)?)\s(.*)(\s(?:start)(?:s|ing)?)(.*)/i
      start_ending_regex = /^(start(?:s|ing)?)\s(.*)(\s(?:\bend|until)(?:s|ing)?)(.*)/i
      if text =~ start_every_regex
        starting = text.match(start_every_regex)[2].strip
        text = text.match(start_every_regex)[4].strip
        event, ending = process_for_ending(text)
      elsif text =~ every_start_regex
        event = text.match(every_start_regex)[2].strip
        text = text.match(every_start_regex)[4].strip
        starting, ending = process_for_ending(text)
      elsif text =~ start_ending_regex
        starting = text.match(start_ending_regex)[2].strip
        ending = text.match(start_ending_regex)[4].strip
        event = 'day'
      else
        event, ending = process_for_ending(text)
      end

      # they gave a phrase so if we can't interpret then we need to raise an error
      if starting
        Tickle.dwrite("starting: #{starting}")
        @start = chronic_parse(pre_filter(starting))
        if @start
          @start.to_time
        else
          raise(InvalidDateExpression,"the starting date expression \"#{starting}\" could not be interpretted")
        end
      else
        @start = options[:start].to_time rescue nil
      end

      if ending
        @until = chronic_parse(pre_filter(ending))
        if @until
          @until.to_time
        else
          raise(InvalidDateExpression,"the ending date expression \"#{ending}\" could not be interpretted")
        end
      else
        @until = options[:until].to_time rescue nil
      end

      @next = nil

      return event
    end

    # process the remaining expression to see if an until, end, ending is specified
    def process_for_ending(text)
      regex = /^(.*)(\s(?:\bend|until)(?:s|ing)?)(.*)/i
      if text =~ regex
        return text.match(regex)[1], text.match(regex)[3]
      else
        return text, nil
      end
    end

    # Normalize natural string removing prefix language
    def pre_filter(text)
      return nil unless text

      text.gsub!(/every(\s)?/, '')
      text.gsub!(/each(\s)?/, '')
      text.gsub!(/repeat(s|ing)?(\s)?/, '')
      text.gsub!(/on the(\s)?/, '')
      text.gsub!(/([^\w\d\s])+/, '')
      text.downcase.strip
    end

    # Split the text on spaces and convert each word into
    # a Token
    def base_tokenize(text) #:nodoc:
      text.split(' ').map { |word| Token.new(word) }
    end

    # normalizes each token
    def post_tokenize
      @tokens.each do |token|
        token.word = normalize(token.original)
      end
    end

    # Clean up the specified input text by stripping unwanted characters,
    # converting idioms to their canonical form, converting number words
    # to numbers (three => 3), and converting ordinal words to numeric
    # ordinals (third => 3rd)
    def normalize(text) #:nodoc:
      normalized_text = text.to_s.downcase
      normalized_text = Numerizer.numerize(normalized_text)
      normalized_text.gsub!(/['"\.]/, '')
      normalized_text.gsub!(/([\/\-\,\@])/) { ' ' + $1 + ' ' }
      # normalized_text.gsub!(/\btoday\b/, 'this day')
      # normalized_text.gsub!(/\btomm?orr?ow\b/, 'next day')
      # normalized_text.gsub!(/\byesterday\b/, 'last day')
      # normalized_text.gsub!(/\bnoon\b/, '12:00')
      # normalized_text.gsub!(/\bmidnight\b/, '24:00')
      # normalized_text.gsub!(/\bbefore now\b/, 'past')
      # normalized_text.gsub!(/\bnow\b/, 'this second')
      # normalized_text.gsub!(/\b(ago|before)\b/, 'past')
      # normalized_text.gsub!(/\bthis past\b/, 'last')
      # normalized_text.gsub!(/\bthis last\b/, 'last')
      # normalized_text.gsub!(/\b(?:in|during) the (morning)\b/, '\1')
      # normalized_text.gsub!(/\b(?:in the|during the|at) (afternoon|evening|night)\b/, '\1')
      # normalized_text.gsub!(/\btonight\b/, 'this night')
      # normalized_text.gsub!(/(?=\w)([ap]m|oclock)\b/, ' \1')
      # normalized_text.gsub!(/\b(hence|after|from)\b/, 'future')
      normalized_text
    end

    # Turns compound numbers, like 'twenty first' => 21
    def combine_multiple_numbers
      if [:number, :ordinal].all? {|type| token_types.include? type}
        number = token_of_type(:number)
        ordinal = token_of_type(:ordinal)
        combined_original = "#{number.original} #{ordinal.original}"
        combined_word = (number.start.to_s[0] + ordinal.word)
        combined_value = (number.start.to_s[0] + ordinal.start.to_s)
        new_number_token = Token.new(combined_original, combined_word, :ordinal, combined_value, 365)
        @tokens.reject! {|token| (token.type == :number || token.type == :ordinal)}
        @tokens << new_number_token
      end
    end

    # Returns an array of types for all tokens
    def token_types
      @tokens.map(&:type)
    end

    protected

    # Returns the next available month based on the current day of the month.
    # For example, if get_next_month(15) is called and the start date is the 10th, then it will return the 15th of this month.
    # However, if get_next_month(15) is called and the start date is the 18th, it will return the 15th of next month.
    def get_next_month(number)
      month = number.to_i < @start.day ? (@start.month == 12 ? 1 : @start.month + 1) : @start.month
    end

    # Return the number of days in a specified month.
    # If no month is specified, current month is used.
    def days_in_month(month=nil)
      month ||= Date.today.month
      days_in_mon = Date.civil(Date.today.year, month, -1).day
    end

    private

    # slightly modified chronic parser to ensure that the date found is in the future
    # first we check to see if an explicit date was passed and, if so, dont do anything.
    # if, however, a date expression was passed we evaluate and shift forward if needed
    def chronic_parse(exp)
      result = Chronic.parse(exp.ordinal_as_number)
      result = Time.local(result.year + 1, result.month, result.day, result.hour, result.min, result.sec) if result && result.to_time < Time.now
      Tickle.dwrite("Chronic.parse('#{exp}') # => #{result}")
      result
    end

  end

  class Token #:nodoc:
    attr_accessor :original, :word, :type, :interval, :start

    def initialize(original, word=nil, type=nil, start=nil, interval=nil)
      @original = original
      @word = word
      @type = type
      @interval = interval
      @start = start
    end

    # Updates an existing token.  Mostly used by the repeater class.
    def update(type, start=nil, interval=nil)
      @start = start
      @type = type
      @interval = interval
    end
  end

  # This exception is raised if an invalid argument is provided to
  # any of Tickle's methods
  class InvalidArgumentException < Exception
  end

  # This exception is raised if there is an issue with the parsing
  # output from the date expression provided
  class InvalidDateExpression < Exception
  end
end
