require 'active_support/concern'

module Hal
  module Serializer
    extend ActiveSupport::Concern

    attr_accessor :builder

    def relation(name, options)
      builder.add_relation(name, options)
    end

    def relations(name, &block)
      builder.add_relations(name, &block)
    end

    def link(options)
      builder.add_link(options)
    end

    def resource(name, options={})
      builder.add_resource(name, options)
    end

    def resources(name, options={})
      builder.add_resources(name, options)
    end

  end

end
