class Tickle::Repeater < Chronic::Tag #:nodoc:
  #
  def self.scan(tokens)
    # for each token
    tokens.each do |token|
      token = self.scan_for_numbers(token)
      token = self.scan_for_ordinal_names(token)
      token = self.scan_for_ordinals(token)
      token = self.scan_for_month_names(token) unless token.type
      token = self.scan_for_day_names(token) unless token.type
      token = self.scan_for_special_text(token) unless token.type
      token = self.scan_for_units(token) unless token.type
    end
    tokens
  end

  def self.scan_for_numbers(token)
    num = Float(token.word) rescue nil
    token.update(:number, num.to_i, num.to_i) if num
    token
  end

  def self.scan_for_ordinal_names(token)
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
    scanner.keys.each do |scanner_item|
      token.update(:ordinal, scanner[scanner_item], 365) if scanner_item =~ token.original
    end
    token
  end
  
  def self.scan_for_ordinals(token)
    regex = /\b(\d*)(st|nd|rd|th)\b/
    token.update(:ordinal, token.original, 365) if !(token.original =~ regex).nil?
    token
  end
  
  def self.scan_for_month_names(token)
    scanner = {/^jan\.?(uary)?$/ => :january,
      /^feb\.?(ruary)?$/ => :february,
      /^mar\.?(ch)?$/ => :march,
      /^apr\.?(il)?$/ => :april,
      /^may$/ => :may,
      /^jun\.?e?$/ => :june,
      /^jul\.?y?$/ => :july,
      /^aug\.?(ust)?$/ => :august,
      /^sep\.?(t\.?|tember)?$/ => :september,
      /^oct\.?(ober)?$/ => :october,
      /^nov\.?(ember)?$/ => :november,
    /^dec\.?(ember)?$/ => :december}
    scanner.keys.each do |scanner_item|
      token.update(:month_name, scanner[scanner_item], 30) if scanner_item =~ token.word
    end
    token
  end

  def self.scan_for_day_names(token)
    scanner = {/^m[ou]n(day)?$/ => :monday,
      /^t(ue|eu|oo|u|)s(day)?$/ => :tuesday,
      /^tue$/ => :tuesday,
      /^we(dnes|nds|nns)day$/ => :wednesday,
      /^wed$/ => :wednesday,
      /^th(urs|ers)day$/ => :thursday,
      /^thu$/ => :thursday,
      /^fr[iy](day)?$/ => :friday,
      /^sat(t?[ue]rday)?$/ => :saturday,
    /^su[nm](day)?$/ => :sunday}
    scanner.keys.each do |scanner_item|
      token.update(:weekday, scanner[scanner_item], 7) if scanner_item =~ token.word
    end
    token
  end

  def self.scan_for_special_text(token)
    scanner = {/^other$/ => :other,
      /^begin(ing|ning)?$/ => :beginning,
      /^start$/ => :beginning,
      /^end$/ => :end,
    /^mid(d)?le$/ => :middle}
    scanner.keys.each do |scanner_item|
      token.update(:special, scanner[scanner_item], 7) if scanner_item =~ token.word
    end
    token
  end

  def self.scan_for_units(token)
    scanner = {/^year(ly)?s?$/ => {:type => :year, :interval => 365, :start => :today},
      /^month(ly)?s?$/ => {:type => :month, :interval => 30, :start => :today},
      /^fortnights?$/ => {:type => :fortnight, :interval => 365, :start => :today},
      /^week(ly)?s?$/ => {:type => :week, :interval => 7, :start => :today},
      /^weekends?$/ => {:type => :weekend, :interval => 7, :start => :saturday},
      /^days?$/ => {:type => :day, :interval => 1, :start => :today},
    /^daily?$/ => {:type => :day, :interval => 1, :start => :today}}
    scanner.keys.each do |scanner_item|
      if scanner_item =~ token.word
        token.update(scanner[scanner_item][:type], scanner[scanner_item][:start], scanner[scanner_item][:interval]) if scanner_item =~ token.word
      end
    end
    token
  end

end
