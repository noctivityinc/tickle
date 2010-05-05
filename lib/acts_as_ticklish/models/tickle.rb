module Tickle
  module ActsAsTicklish
    class Tickle < ActiveRecord::Base
      belongs_to :ticklish,  :polymorphic => true

      
    end
  end
end
