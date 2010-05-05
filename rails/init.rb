require 'active_record'

require 'tickle'
require 'acts_as_ticklish/acts_as_ticklish'
require 'acts_as_ticklish/models/tickle'

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Tickle::ActsAsTicklish
end

