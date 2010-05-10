module Tickle #:nodoc:
  class << self #:nodoc:

    # The heavy lifting.  Goes through each token groupings to determine what natural language should either by
    # parsed by Chronic or returned.  This methodology makes extension fairly simple, as new token types can be
    # easily added in repeater and then processed by the guess method
    #
    def guess()
      return nil if @tokens.empty?

      guess_unit_types
      guess_weekday unless @next
      guess_month_names unless @next
      guess_number_and_unit unless @next
      guess_ordinal unless @next
      guess_ordinal_and_unit unless @next
      guess_special unless @next

      # check to see if next is less than now and, if so, set it to next year
      @next = Time.local(@next.year + 1, @next.month, @next.day, @next.hour, @next.min, @next.sec) if @next && @next.to_date < @start.to_date

      # return the next occurrence
      return @next.to_time if @next
    end

    def guess_unit_types
      @next = @start.bump(:day) if token_types.same?([:day])
      @next = @start.bump(:week) if token_types.same?([:week])
      @next = @start.bump(:month) if token_types.same?([:month])
      @next = @start.bump(:year) if token_types.same?([:year])
    end

    def guess_weekday
      @next = chronic_parse_with_start("#{token_of_type(:weekday).start.to_s}") if token_types.same?([:weekday])
    end

    def guess_month_names
      @next = chronic_parse_with_start("#{Date::MONTHNAMES[token_of_type(:month_name).start]} 1") if token_types.same?([:month_name])
    end

    def guess_number_and_unit
      @next = @start.bump(:day, token_of_type(:number).interval) if token_types.same?([:number, :day])
      @next = @start.bump(:week, token_of_type(:number).interval) if token_types.same?([:number, :week])
      @next = @start.bump(:month, token_of_type(:number).interval) if token_types.same?([:number, :month])
      @next = @start.bump(:year, token_of_type(:number).interval) if token_types.same?([:number, :year])
      @next = chronic_parse_with_start("#{token_of_type(:month_name).word} #{token_of_type(:number).start}") if token_types.same?([:number, :month_name])
      @next = chronic_parse_with_start("#{token_of_type(:specific_year).word}-#{token_of_type(:month_name).start}-#{token_of_type(:number).start}") if token_types.same?([:number, :month_name, :specific_year])
    end

    def guess_ordinal
      @next = handle_same_day_chronic_issue(@start.year, @start.month, token_of_type(:ordinal).start) if token_types.same?([:ordinal])
    end

    def guess_ordinal_and_unit
      @next = handle_same_day_chronic_issue(@start.year, token_of_type(:month_name).start, token_of_type(:ordinal).start) if token_types.same?([:ordinal, :month_name])
      @next = handle_same_day_chronic_issue(@start.year, @start.month, token_of_type(:ordinal).start) if token_types.same?([:ordinal, :month])
      @next = handle_same_day_chronic_issue(token_of_type(:specific_year).word, token_of_type(:month_name).start, token_of_type(:ordinal).start) if token_types.same?([:ordinal, :month_name, :specific_year])

      if token_types.same?([:ordinal, :weekday, :month_name])
        @next = chronic_parse_with_start("#{token_of_type(:ordinal).word} #{token_of_type(:weekday).start.to_s} in #{Date::MONTHNAMES[token_of_type(:month_name).start]}")
        @next = handle_same_day_chronic_issue(@start.year, token_of_type(:month_name).start, token_of_type(:ordinal).start) if @next.to_date == @start.to_date
      end

      if token_types.same?([:ordinal, :weekday, :month])
        @next = chronic_parse_with_start("#{token_of_type(:ordinal).word} #{token_of_type(:weekday).start.to_s} in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}")
        @next = handle_same_day_chronic_issue(@start.year, @start.month, token_of_type(:ordinal).start) if @next.to_date == @start.to_date
      end
    end

    def guess_special
      guess_special_other
      guess_special_beginning unless @next
      guess_special_middle unless @next
      guess_special_end unless @next
    end

    private

    def guess_special_other
      @next = @start.bump(:day, 2) if token_types.same?([:special, :day]) && token_of_type(:special).start == :other
      @next = @start.bump(:week, 2)  if token_types.same?([:special, :week]) && token_of_type(:special).start == :other
      @next = chronic_parse_with_start('2 months from now') if token_types.same?([:special, :month]) && token_of_type(:special).start == :other
      @next = chronic_parse_with_start('2 years from now') if token_types.same?([:special, :year]) && token_of_type(:special).start == :other
    end

    def guess_special_beginning
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :beginning then @next = chronic_parse_with_start('Sunday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :beginning then @next = Date.civil(@start.year, @start.month + 1, 1); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :beginning then @next = Date.civil(@start.year+1, 1, 1); end
    end

    def guess_special_end
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :end then @next = chronic_parse_with_start('Saturday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :end then @next = Date.civil(@start.year, @start.month, -1); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :end then @next = Date.new(@start.year, 12, 31); end
    end

    def guess_special_middle
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :middle then @next = chronic_parse_with_start('Wednesday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :middle then
        @next = (@start.day > 15 ? Date.civil(@start.year, @start.month + 1, 15) : Date.civil(@start.year, @start.month, 15))
      end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :middle then
        @next = (@start.day > 15 && @start.month > 6 ? Date.new(@start.year+1, 6, 15) : Date.new(@start.year, 6, 15))
      end
    end

    def token_of_type(type)
      @tokens.detect {|token| token.type == type}
    end

    private

    # runs Chronic.parse with now being set to the specified start date for Tickle parsing
    def chronic_parse_with_start(exp)
      Tickle.dwrite("date expression: #{exp}, start: #{@start}")
      Chronic.parse(exp, :now => @start)
    end

    # needed to handle the unique situation where a number or ordinal plus optional month or month name is passed that is EQUAL to the start date since Chronic returns that day.
    def handle_same_day_chronic_issue(year, month, day)
      Tickle.dwrite("year (#{year}), month (#{month}), day (#{day})")
      arg_date = (Date.new(year.to_i, month.to_i, day.to_i) == @start.to_date) ? Time.local(year, month+1, day) : Time.local(year, month, day)
      return arg_date
    end


  end
end
