module HalResponder
  def to_json
    serializer = Hal.serializer_for(resource)
    resource = Hal.build serializer
    resource.to_json
    # instruction = Instruction.new(serializer)
    # hal_resource = Hal::Builder.new(instruction)
    # hal_resource.to_json
  end
end


module Hal
  def build(serializer)
    builder.new(serializer) do |builder|
      builder.add_attributes_instructions
      builder.add_links_instructions if serializer.respond_to?(:links)
      builder.add_embedded_instructions if serializer.respond_to?(:embedded)
    end
    builder.as_json
  end
end
# serializer :comment_threads do
#   attributes :comment_threads, :group
#   links do
#     relations :comment_threads do |comment_thread|
#       link href: comment_thread_url
#     end
#   end

#   embedded do
#     resources :comment_threads
#   end
# end



serializer.links


serializer.relations


def relations(&block)
  builder.add_instruction(:relations, context: build.current_context)
  builder.current_context = # switch context here
  # each do |comment|
    yield(builder.current_context)
  # end
end

def link
  builder.add_instruction(:link, context: build.current_context)
end

# builder.new(serializer)
# builder.new(:serializer) do |builder|
#   builder.add_attributes_instructions
#   builder.add_links_instructions
#   builder.add_embedded_instructions
# end
# builder.resource -> resource.as_json
if serializer.respond_to?(:links)
  builder.add_instruction(:links, context: build.current_context)
  builder.current_context = # switch context here
end


#
module Hal
  class Node
    attr_accessor :data

    def initialize(options)
      @type = options.delete(:type)
    end

    def as_json
      self.children.each do |node|
        self.attach_node(node)
      end
      self.attach_properties
    end

    def attach_node(node)
      data[node.name] = node.as_json
    end

  end
end

module Hal
  class Builder
    def initialize(serializer)
      @serializer = serializer
      @root_node = Hal::Node.new(type: :root)
      yield self
    end

    def add_attributes

    end

    def as_json
      @root_node.as_json
    end
  end
end