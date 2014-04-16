require "active_support/core_ext/string/inflections"
require 'hal/serializer'
require 'hal/builder'
require 'hal/node'

module Hal
  def self.serialize(resource, options={})
    serializer = Hal.serializer_for(resource)
    options = { serializer: serializer, recursive: true }.merge(options)
    builder = Hal::Builder.new(options) do |builder|
      builder.add_attributes if serializer.respond_to?(:attributes)
      builder.add_links if serializer.respond_to?(:links)
      builder.add_embedded if serializer.respond_to?(:embedded) && builder.recursive?
    end
    builder.as_json
  end

  def self.serializer_for(resource)
    klass = (resource.class.to_s + 'Serializer').constantize
    klass.new(resource)
  end

end