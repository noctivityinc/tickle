module Tickle
  class << self

    def parse(text, specified_options = {})
      # get options and set defaults if necessary
      default_options = {:start => Time.now}
      options = default_options.merge specified_options

      # ensure the specified options are valid
      specified_options.keys.each do |key|
        default_options.keys.include?(key) || raise(InvalidArgumentException, "#{key} is not a valid option key.")
      end
      Chronic.parse(specified_options[:start]) || raise(InvalidArgumentException, ':start specified is not a valid datetime.') if specified_options[:start]

      # remove every is specified
      text = text.gsub(/^every\s\b/, '')

      # put the text into a normal format to ease scanning using Chronic
      text = pre_normalize(text)
      text = Chronic.pre_normalize(text)
      text = numericize_ordinals(text)

      # check to see if this event starts some other time and reset now
      event, starting = text.split('starting')
      @start = (Chronic.parse(starting) || options[:start])

      # split into tokens
      @tokens = base_tokenize(event)

      # scan the tokens with each token scanner
      @tokens = Repeater.scan(@tokens)

      # remove all tokens without a type
      @tokens.reject! {|token| token.type.nil? }

      # dwrite @tokens.inspect

      return guess
    end

    # Normalize natural string removing prefix language
    def pre_normalize(text)
      normalized_text = text.gsub(/^every\s\b/, '')
      normalized_text = text.gsub(/^each\s\b/, '')
      normalized_text = text.gsub(/^on the\s\b/, '')
      normalized_text
    end

    # Split the text on spaces and convert each word into
    # a Token
    def base_tokenize(text) #:nodoc:
      text.split(' ').map { |word| Token.new(word) }
    end

    # Convert ordinal words to numeric ordinals (third => 3rd)
    def numericize_ordinals(text) #:nodoc:
      text = text.gsub(/\b(\d*)(st|nd|rd|th)\b/, '\1')
    end

    # Returns an array of types for all tokens
    def token_types
      @tokens.map(&:type)
    end
  end

  class Token #:nodoc:
    attr_accessor :word, :type, :interval, :start

    def initialize(word)
      @word = word
      @type = @interval = @start = nil
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
