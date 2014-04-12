module Hal
  class Instruction
    attr_accessor :serializer, :type, :parent, :children, :params, :name, :objects

    def initialize(options)
      @serializer = options.delete(:serializer)
      @type = options.delete(:type)
      @name = options.delete(:name)
      @objects = options.delete(:objects)
      @object = options.delete(:object)
      @children = []

      @parent = options.delete(:parent)

      if resource? && serializer.respond_to?(:links)
        links_instruction = Instruction.new(type: :links)
        self.add_child(links_instruction)
        links_instruction.add_child(serializer.links)
      end

      if resource? && serializer.respond_to?(:embedded)
        embedded_instruction = Instruction.new(type: :embedded)
        self.add_child(embedded_instruction)
        embedded_instruction.add_child(serializer.embedded)
      end

      if resources? && objects
        objects.each do |object|
          serializer = Hal.serializer_for(object)
          self.add_child(Instruction.new(serializer: serializer, type: :resource))
        end
      end

      if resource? && parent
        serializer = Hal.serializer_for(serializer.object)
        self.add_child(Instruction.new(serializer: serializer, type: :resource))
      end

    end

    # def set_parent_child(parent)
    #   @parent = parent
    #   if !@parent.children.include?(self)
    #     @parent.add_child(self)
    #   end
    # end

    def add_child(child)
      # add child needs also establish the parent
      child.parent = self
      self.children << child
    end

    def resource?
      self.type == :resource
    end

    def resources?
      self.type == :resources
    end
  end
end
