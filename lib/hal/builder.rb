module Hal
  class Builder
    attr_accessor :serializer

    def initialize(options)
      @serializer = options.delete(:serializer)
      @root_node = options.delete(:root) || Hal::Node.new(type: :root)
      @current_node = options.delete(:current) || @root_node;
      @recursive = options.delete(:recursive)
      @serializer.builder = self
      yield self
    end

    def recursive?
      @recursive
    end

    def add_attributes
      serializer.attributes.each do |attr|
        @current_node.add_property(attr, serializer.public_send(attr))
      end
    end

    def add_links
      current = @current_node
      begin
        node = add__links
        @current_node = node
        @serializer.links
      ensure
        @current_node = current
      end
    end

    def add_embedded
      current = @current_node
      begin
        node = add__embedded
        @current_node = node
        @serializer.embedded
      ensure
        @current_node = current
      end
    end

    def add__links
      node = Hal::Node.new(type: :links, name: '_links')
      @current_node.add_child(node)
      node
    end

    def add_relation(name, options)
      node = Hal::Node.new(type: :relation, name: name, properties: options)
      @current_node.add_child(node)
    end

    def add_relations(name)
      objects = @serializer.instance_variable_get("@#{name}")
      return unless objects

      current = @current_node
      begin
        node = Hal::Node.new(type: :relations, name: name)
        @current_node.add_child(node)
        @current_node = node


        objects.each { |object| yield(object) }
      ensure
        @current_node = current
      end
    end

    def add_link(options)
      node = Hal::Node.new(type: :link, properties: options)
      @current_node.add_child(node)
    end

    def add__embedded
      node = Hal::Node.new(type: :embedded, name: '_embedded')
      @current_node.add_child(node)
      node
    end

    def add_resource(name, options={})
      resource = @serializer.instance_variable_get("@#{name}")
      # skip of resource is not found
      return unless resource

      node = Hal::Node.new(type: :resource, name: name)
      @current_node.add_child(node)
      current = @current_node
      begin
        @current_node = node
        Hal.serialize(resource, root: @root_node, current: @current_node, recursive: false)
      ensure
        @current_node = current
      end
    end

    def add_resources(name, options={})
      resources = @serializer.instance_variable_get("@#{name}") || []
      node = Hal::Node.new(type: :resources, name: name)
      @current_node.add_child(node)
      current = @current_node
      begin
        @current_node = node
        resources.each do |resource|
          Hal.serialize(resource, root: @root_node, current: @current_node, recursive: false)
        end
      ensure
        @current_node = current
      end

    end

    def as_json
      @current_node.as_json
    end
  end
end