module Tickle
  class << self

    def parse(text, specified_options = {})
      # get options and set defaults if necessary
      default_options = {:start => Time.now}
      options = default_options.merge specified_options

      # ensure the specified options are valid
      specified_options.keys.each do |key|
        raise(InvalidArgumentException, "#{key} is not a valid option key.") unless default_options.keys.include?(key)
      end
      raise(InvalidArgumentException, ':start specified is not a valid datetime.') unless  (is_date(specified_options[:start]) || Chronic.parse(specified_options[:start])) if specified_options[:start]

      # check to see if this event starts some other time and reset now
      event, starting = text.split('starting')
      @start = (Chronic.parse(starting) || options[:start])
      @next = nil

      # put the text into a normal format to ease scanning using Chronic
      event = pre_tokenize(event)

      # split into tokens
      @tokens = base_tokenize(event)

      # process each original word for implied word
      post_tokenize

      # scan the tokens with each token scanner
      @tokens = Repeater.scan(@tokens)

      # remove all tokens without a type
      @tokens.reject! {|token| token.type.nil? }

      # combine number and ordinals into single number
      combine_multiple_numbers

      @tokens.each {|x| puts x.inspect} if Tickle.debug

      return guess
    end

    # Normalize natural string removing prefix language
    def pre_tokenize(text)
      normalized_text = text.gsub(/^every\s\b/, '')
      normalized_text = text.gsub(/^each\s\b/, '')
      normalized_text = text.gsub(/^on the\s\b/, '')
      normalized_text.downcase
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
      normalized_text.gsub!(/\btoday\b/, 'this day')
      normalized_text.gsub!(/\btomm?orr?ow\b/, 'next day')
      normalized_text.gsub!(/\byesterday\b/, 'last day')
      normalized_text.gsub!(/\bnoon\b/, '12:00')
      normalized_text.gsub!(/\bmidnight\b/, '24:00')
      normalized_text.gsub!(/\bbefore now\b/, 'past')
      normalized_text.gsub!(/\bnow\b/, 'this second')
      normalized_text.gsub!(/\b(ago|before)\b/, 'past')
      normalized_text.gsub!(/\bthis past\b/, 'last')
      normalized_text.gsub!(/\bthis last\b/, 'last')
      normalized_text.gsub!(/\b(?:in|during) the (morning)\b/, '\1')
      normalized_text.gsub!(/\b(?:in the|during the|at) (afternoon|evening|night)\b/, '\1')
      normalized_text.gsub!(/\btonight\b/, 'this night')
      normalized_text.gsub!(/(?=\w)([ap]m|oclock)\b/, ' \1')
      normalized_text.gsub!(/\b(hence|after|from)\b/, 'future')
      normalized_text = numericize_ordinals(normalized_text)
    end

    # Convert ordinal words to numeric ordinals (third => 3rd)
    def numericize_ordinals(text) #:nodoc:
      text = text.gsub(/\b(\d*)(st|nd|rd|th)\b/, '\1')
    end

    # Turns compound numbers, like 'twenty first' => 21
    def combine_multiple_numbers
      if [:number, :ordinal].all? {|type| token_types.include? type}
        number = token_of_type(:number)
        ordinal = token_of_type(:ordinal)
        combined_value = (number.start.to_s[0] + ordinal.start.to_s)
        new_number_token = Token.new(combined_value, combined_value, :ordinal, combined_value, 365)
        @tokens.reject! {|token| (token.type == :number || token.type == :ordinal)}
        @tokens << new_number_token
      end
    end

    # Returns an array of types for all tokens
    def token_types
      @tokens.map(&:type)
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
end
