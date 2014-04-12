module Hal
  def self.serializer_for(resource)
    klass = (resource.class.to_s + 'Serializer').constantize
  end
end

require 'instruction'
require 'serializer'

