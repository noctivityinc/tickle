module Tickle
  class << self

    def guess()
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
      interval = 1 if token_types.same?([:day])
      interval = 7 if token_types.same?([:week])
      interval = Tickle.days_in_month if token_types.same?([:month])
      interval = 365 if token_types.same?([:year])
      compute_next(interval)
    end

    def guess_weekday
      @next = chronic_parse("#{token_of_type(:weekday).start.to_s}") if token_types.same?([:weekday])
    end

    def guess_month_names
      @next = chronic_parse("#{token_of_type(:month_name).start.to_s} 1") if token_types.same?([:month_name])
    end

    def guess_number_and_unit
      interval = token_of_type(:number).interval if token_types.same?([:number, :day])
      interval = (token_of_type(:number).interval * 7) if token_types.same?([:number, :week])
      interval = (token_of_type(:number).interval * Tickle.days_in_month) if token_types.same?([:number, :month])
      interval = (token_of_type(:number).interval * 365) if token_types.same?([:number, :year])
      compute_next(interval)
    end

    def guess_ordinal
      @next = chronic_parse("#{token_of_type(:ordinal).word} day in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}") if token_types.same?([:ordinal]) 
    end

    def guess_ordinal_and_unit
      @next = chronic_parse("#{token_of_type(:ordinal).word} day in #{token_of_type(:month_name).start.to_s} ") if token_types.same?([:ordinal, :month_name])
      @next = chronic_parse("#{token_of_type(:ordinal).word} day in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}") if token_types.same?([:ordinal, :month]) 
      @next = chronic_parse("#{token_of_type(:ordinal).word} #{token_of_type(:weekday).start.to_s} in #{token_of_type(:month_name).start.to_s}") if token_types.same?([:ordinal, :weekday, :month_name]) 
      @next = chronic_parse("#{token_of_type(:ordinal).word} #{token_of_type(:weekday).start.to_s} in #{Date::MONTHNAMES[get_next_month(token_of_type(:ordinal).start)]}") if token_types.same?([:ordinal, :weekday, :month]) 
      @next = chronic_parse("#{token_of_type(:month_name).word} #{token_of_type(:ordinal).start} #{token_of_type(:specific_year).word}") if token_types.same?([:ordinal, :month_name, :specific_year])
    end

    def guess_special
      guess_special_other
      guess_special_beginning unless @next
      guess_special_middle unless @next
      guess_special_end unless @next
    end

    private

    def guess_special_other
      interval = 2 if token_types.same?([:special, :day]) && token_of_type(:special).start == :other
      interval = 14 if token_types.same?([:special, :week]) && token_of_type(:special).start == :other
      @next = chronic_parse('2 months from now') if token_types.same?([:special, :month]) && token_of_type(:special).start == :other 
      @next = chronic_parse('2 years from now') if token_types.same?([:special, :year]) && token_of_type(:special).start == :other 
      compute_next(interval)
    end

    def guess_special_beginning
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :beginning then @next = chronic_parse('Sunday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :beginning then @next = Date.civil(@start.year, @start.month + 1, 1); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :beginning then @next = Date.civil(@start.year+1, 1, 1); end
    end

    def guess_special_end
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :end then @next = chronic_parse('Saturday'); end
      if token_types.same?([:special, :month]) && token_of_type(:special).start == :end then @next = Date.civil(@start.year, @start.month, -1); end
      if token_types.same?([:special, :year]) && token_of_type(:special).start == :end then @next = Date.new(@start.year, 12, 31); end
    end

    def guess_special_middle
      if token_types.same?([:special, :week]) && token_of_type(:special).start == :middle then @next = chronic_parse('Wednesday'); end
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

    def compute_next(interval)
      # defines the next occurrence of this tickle if not set in a guess routine
      @next ||= @start + (interval * 60 * 60 * 24) if interval
    end
    
    def chronic_parse(exp)
      puts "date expression: #{exp}" if Tickle.debug
      Chronic.parse(exp, :now => @start)
    end


  end
end
