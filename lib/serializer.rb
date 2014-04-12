require 'active_support/concern'
require "active_support/core_ext/string/inflections"

module Hal
  module Serializer
    extend ActiveSupport::Concern

    attr_reader :instruction

    def _links(instruction)
      instruction.add_child(self.links)
    end

    def _embedded
    end

    def relations(name, &block)
      # infer instance variable from its name
      objects = self.instance_variable_get("@#{name}")
      instruction = Instruction.new(type: :relations, objects: objects, name: name)
      objects.each do |object|
        instruction.add_child(yield(object))
      end
      return instruction
    end

    def relation(name, options={})
      object = self.instance_variable_get("@#{name}")
      instruction = Instruction.new(type: :relation, object: object, name: name)
    end

    def link(options)
      instruction = Instruction.new(type: :link)
      instruction.params = options
      instruction
    end

    def resource(name)
      object = self.instance_variable_get("@#{name}")
      instruction = Instruction.new(type: :resource, object: object)
    end

    def resources(name)
      objects = self.instance_variable_get("@#{name}")
      instruction = Instruction.new(type: :resources, objects: objects)
    end
  end
end


# if serializer.respond_to?(:links)
#     instruction.new(:build, link)
#     serializer.links

# Instruction.new(serializer)
