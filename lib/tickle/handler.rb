module Tickle
  class << self

    def guess()
      interval = guess_unit_types
      interval ||= guess_weekday
      interval ||= guess_month_names
      interval ||= guess_number_and_unit
      interval ||= guess_ordinal
      interval ||= guess_ordinal_and_unit
      interval ||= guess_special

      # defines the next occurrence of this tickle if not set in a guess routine
      @next ||= @start + (interval * 60 * 60 * 24) if interval

      # check to see if the start date is > NOW and, if so, set the next occurrence = start
      @next = @start if @start.to_time > Time.now

      # return the next occurrence
      return @next.to_time if interval
    end

    def guess_unit_types
      interval = 0 if token_types.same?([:day])
      interval = 7 if token_types.same?([:week])
      interval = 30 if token_types.same?([:month])
      interval = 365 if token_types.same?([:year])
      interval
    end

    def guess_weekday
      if token_types.same?([:weekday]) then
        @start = Chronic.parse(token_of_type(:weekday).start.to_s)
        interval = 7
      end
      interval
    end

    def guess_month_names
      if token_types.same?([:month_name]) then
        @start = Chronic.parse("#{token_of_type(:month_name).start.to_s} 1")
        interval = 30
      end
      interval
    end

    def guess_number_and_unit
      interval = token_of_type(:number).interval if token_types.same?([:number, :day])
      interval = (token_of_type(:number).interval * 7) if token_types.same?([:number, :week])
      interval = (token_of_type(:number).interval * 30) if token_types.same?([:number, :month])
      interval = (token_of_type(:number).interval * 365) if token_types.same?([:number, :year])
      interval
    end

    def guess_ordinal
      if token_types.same?([:ordinal]) then interval = 365; @next = Chronic.parse("#{token_of_type(:ordinal).start} day in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}"); end
      interval
    end

    def guess_ordinal_and_unit
      parse_text = ''
      if token_types.same?([:ordinal, :month_name]) then interval = 365; @next = Chronic.parse("#{token_of_type(:ordinal).original} day in #{token_of_type(:month_name).start.to_s}"); end
      if token_types.same?([:ordinal, :month]) then interval = 365; @next = Chronic.parse("#{token_of_type(:ordinal).start} day in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}"); end
      if token_types.same?([:ordinal, :weekday, :month_name]) then interval = 365; @next = Chronic.parse("#{token_of_type(:ordinal).original} #{token_of_type(:weekday).start.to_s} in #{token_of_type(:month_name).start.to_s}"); end
      if token_types.same?([:ordinal, :weekday, :month]) then interval = 365; @next = Chronic.parse("#{token_of_type(:ordinal).original} #{token_of_type(:weekday).start.to_s} in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}"); end
      interval
    end

    def guess_special
      interval = guess_special_other
      interval ||= guess_special_beginning
      interval ||= guess_special_middle
      interval ||= guess_special_end
    end

    private

    def guess_special_other
      interval = 2 if token_types.same?([:special, :day]) && token_of_type(:special).start == :other
      interval = 14 if token_types.same?([:special, :week]) && token_of_type(:special).start == :other
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :other then interval = 60;  @next = Chronic.parse('2 months from now'); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :other then interval = 730;  @next = Chronic.parse('2 years from now'); end
      interval
    end

    def guess_special_beginning
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :beginning then interval = 7;  @start = Chronic.parse('Sunday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :beginning then interval = 30;  @start = Chronic.parse('1st day next month'); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :beginning then interval = 365;  @start = Chronic.parse('1st day next year'); end
      interval
    end

    def guess_special_end
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :end then interval = 7;  @start = Chronic.parse('Saturday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :end then interval = 30;  @start = Date.new(Date.today.year, Date.today.month, Date.today.days_in_month); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :end then interval = 365;  @start = Date.new(Date.today.year, 12, 31); end
      interval
    end

    def guess_special_middle
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :middle then interval = 7;  @start = Chronic.parse('Wednesday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :middle then
        interval = 30;
        @start = (Date.today.day > 15 ? Chronic.parse('15th day of next month') : Date.new(Date.today.year, Date.today.month, 15))
      end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :middle then
        interval = 365;
        @start = (Date.today.day > 15 && Date.today.month > 6 ? Date.new(Date.today.year+1, 6, 15) : Date.new(Date.today.year, 6, 15))
      end
      interval
    end

    def token_of_type(type)
      @tokens.detect {|token| token.type == type}
    end

    private

    def get_next_month(ordinal)
      ord_to_int = ordinal.gsub(/\b(\d*)(st|nd|rd|th)\b/,'\1').to_i
      month = (ord_to_int < Date.today.day ? Date.today.month + 1 : Date.today.month)
    end

  end
end
