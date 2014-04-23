module Hal
  class Builder
    Hal::Builder::NoSerializerError = Class.new(StandardError)

    def initialize(options)
      @serializer = options.delete(:serializer) || fail(Hal::Builder::NoSerializerError)
      @root_node = options.delete(:root) || Hal::Node.new(type: :root)
      @current_node = options.delete(:current) || @root_node;
      @recursive = options.delete(:recursive)
      @serializer.builder = self
      yield self if block_given?
    end

    def recursive?
      !!@recursive
    end

    def add_attributes
      @serializer.attributes.each do |attr|
        @current_node.add_property(attr, @serializer.public_send(attr))
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

    def add_relation(name, properties)
      attach_new_node(type: :relation, name: name, properties: properties)
    end

    def add_relations(name)
      objects = resource_for(name)
      return unless objects

      current = @current_node
      begin
        node = attach_new_node(type: :relations, name: name)
        @current_node = node

        objects.each { |object| yield(object) }
      ensure
        @current_node = current
      end
    end

    def add_link(options)
      attach_new_node(type: :link, properties: options)
    end

    def add_resource(name, options={})
      resource = resource_for(name)
      # skip of resource is not found
      return unless resource

      node = attach_new_node(type: :resource, name: name)
      current = @current_node
      begin
        @current_node = node
        Hal.serialize(resource, root: @root_node, current: @current_node, recursive: false)
      ensure
        @current_node = current
      end
    end

    def add_resources(name, options={})
      resources = resource_for(name) || []
      node = attach_new_node(type: :resources, name: name)
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

    private

    # Create a '_link' node
    def add__links
      attach_new_node(type: :links, name: '_links')
    end

    # Create a '_embedded' node
    def add__embedded
      attach_new_node(type: :embedded, name: '_embedded')
    end

    # Making assumptions that the serializer always holds the resource(s)
    # as instance variable
    def resource_for(name)
      @serializer.instance_variable_get("@#{name}")
    end

    def attach_new_node(options)
      node = Hal::Node.new(options)
      @current_node.add_child(node)
      node
    end
  end
end
