require 'active_record'
require 'active_view'

require 'tickle'
require 'acts_as_ticklish/acts_as_ticklish'
require 'acts_as_ticklish/model/tickle'

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Tickle::ActsAsTicklish
end

