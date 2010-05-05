module Tickle
  module ActsAsTicklish
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
    
    module ClassMethods
      # need to add explaination here later
      
      def acts_as_ticklish(options = {})
        # don't allow multiple calls
        return if self.included_modules.include?(Tickle::ActsAsTicklish::InstanceMethods)

        belongs_to :tickle, :as  => :ticklish, :class_name => 'Tickle::ActsAsTicklish::Tickle'
        
        include Tickle::ActsAsTicklish::InstanceMethods
      end
      

    end

    module InstanceMethods

    end
  end
end

