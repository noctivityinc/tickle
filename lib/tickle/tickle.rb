module Tickle
  class << self
    
    def parse(text, specified_options = {})
      # get options and set defaults if necessary
      default_options = {:now => Time.now}
      options = default_options.merge specified_options
            
      # ensure the specified options are valid
      specified_options.keys.each do |key|
        default_options.keys.include?(key) || raise(InvalidArgumentException, "#{key} is not a valid option key.")
      end
      Chronic.parse(options[:now]) || rails(InvalidArgumentException, ':now specified is not a valid datetime.')
      
      # store now for later =)
      @now = options[:now]
      
      # put the text into a normal format to ease scanning using Chronic
      text = Chronic.pre_normalize(text)
      
      return text
    end
    
  end
end