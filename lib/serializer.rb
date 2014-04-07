require 'active_support/concern'

module Hal
  module Serializer
    extend ActiveSupport::Concern

    attr_reader :instruction

    def _links

    end

    def _embedded
    end

    def relations
    end

    def relation()
    end

    def link
    end

    def resource
    end

    def resources
    end
  end
end


# if serializer.respond_to?(:links)
#     instruction.new(:build, link)
#     serializer.links

# Instruction.new(serializer)
