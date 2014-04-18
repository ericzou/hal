module Hal
  class Node
    attr_accessor :children, :properties, :parent, :name, :type

    def initialize(options)
      @type = options.delete(:type)
      @children = []
      @data = {}
      @name = options.delete(:name)
      @properties = options.delete(:properties) || {}
    end

    def as_json
      self.children.each do |node|
        self.attach_node(node)
      end
      self.attach_properties
      return @data
    end

    def attach_node(node)
      if node.name
        @data[node.name] = node.as_json
      else
        # nodes without names are assumed to be arrays
        # e.g. comments: [
        #   { href: 'http://comment1'},
        #   { href: 'http://comment2'},
        # ]
        @data = [] unless @data.kind_of?(Array)
        @data << node.as_json
      end
    end

    def attach_properties
      @properties.each { |key, value| @data[key] = value }
    end

    def add_property(key, value)
      @properties[key] = value
    end

    def property(key)
      @properties[key]
    end

    def add_child(node)
      node.parent = self
      self.children << node
    end

  end
end
