require 'spec_helper'

describe 'Link' do
end


class CommentThreadsSerializer

  def initialize(comment_threads)
    @comment_threads = comment_threads;
  end

  def links
    relations :comment_threads do |comment_thread|
      link href: comment_thread_url
    end
  end

  def embedded
    resources :commend_threads, each_serializer: CommentThreadSerializer
  end
end

# builder
# resource
# relation
# link
# embedded


module Hal
  class Serializer

    def links
    end
  end
end

builder = Hal::Builder.new

serializer = CommentThreadsSerializer.new(@comment_threads)

builder.build_resource
  builder.build_attributes(serialzier.attributes)
  builder.build_links(serialzier.links)
    builder.add_relations

  builder.build_embedded(serialzier.embedded) # only 1 level deep
    builder.build_resource

serializer.resource # => <#Resource> as_json

# resource stores the data and has as_json, to_json methods
resource.relations # => [self, items, comment_threads]
resource.relation(:self) # => { href: ... }
resource.href(:self) # => 'http://localhost:/api/comment_threads/12
resource.href(:comment_threads) # => ['http://localhost:/api/comment_threads/12', 'http://localhost:/api/comment_threads/13']


# possible an instructuion object from the serialzier
# serializer.links -> <#Instruction> instruction.type: links, ctx: serializer_context
# serializer.relation(comment_threads) -> <#Instruction> instruction.relations.first: comment_threads, ctx: serializer_context/comment_thread
