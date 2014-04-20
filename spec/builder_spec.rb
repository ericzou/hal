require 'spec_helper'

describe 'Builder when initialized' do
  let(:serializer) { ASerializer.new }
  let(:builder) { builder = Hal::Builder.new(serializer: serializer) }

  it 'is not recursive' do
    expect(builder.recursive?).to be_false
  end

  it 'has a root node' do
    expect(builder).to have_instance(:root_node)
  end

  it 'has a current node' do
    expect(builder).to have_instance(:current_node)
  end

  it 'assign self to the serializer' do
    expect(builder).to have_instance(serializer)
  end
end

describe 'Builder initialized with options' do
  let(:serializer) { ASerializer.new }

  def builder(options = {})
    Hal::Builder.new(options)
  end

  before do
    @options = { serializer: serializer }
  end

  it 'raises error when serialzier not supplied' do
    expect{ builder }.to raise_error Hal::Builder::NoSerializerError
  end

  it 'sets recurisve' do
    @options.merge!({ recursive: true })
    expect(builder(@options).recursive?).to be_true
  end

  it 'sets root node' do
    root = double
    @options.merge!({ root: root })
    expect(builder(@options)).to have_instance(root)
  end

  it 'sets current node' do
    current = double
    @options.merge!({ current: current })
    expect(builder(@options)).to have_instance(current)
  end
end

describe 'Builder #add_attributes' do
  class ASerializer
    def attributes
      [:foo, :bar]
    end

    def foo; 'foo'; end;
    def bar; 'bar'; end
  end
  let(:serializer) { ASerializer.new }
  let(:builder) { Hal::Builder.new(serializer: serializer) }
  it 'adds all attributes from serializer to the current node' do
    properties = builder.instance_variable_get('@current_node').properties
    builder.add_attributes
    expect(properties).to eq({ foo: 'foo', bar: 'bar'})
  end
end

describe 'Builder #add_links' do
  it 'creates a _links node under the current node' do
  end

  it 'invokes serializer#links' do
  end
end

describe 'Builder #add_embedded' do
  it 'creates a _embedded node under the current node' do
  end

  it 'invokes serializer#embedded' do
  end
end

describe 'Builder #add_relation' do
  it 'creates a relation node under the current node' do
  end
end

describe 'Builder #add_relations' do
  it 'creates a relations node under the current node' do
  end

  it 'yields with individual resource' do
  end
end

describe 'Builder #add_link' do
  it 'creates a link node under the current node' do
  end
end

describe 'Builder #add_resource' do
  it 'creates a resource node under the current node' do
  end

  it 'serializes the added resource' do
  end
end

describe 'Builder #add_resources' do
  it 'creates a resources node under the current node' do
  end

  it 'serializes each added resource' do
  end
end



describe 'Builder when adding attributes' do
  let(:serializer) { ASerializer.new }
  let(:builder) { builder = Hal::Builder.new(serializer: serializer) }

  it
end

# describe 'Builder #resource' do
#   let(:builder) { Hal::Builder.new }
#   it 'returns the resource in curent context' do
#     builder.curernt_context = :root
#     expect(builder.resource).to equal(builder.root_resource)
#   end
# end

# describe 'Builder when building attributes' do
#   let(:user) { User.new('Jane', 'jane@example.com', '123 main st.') }
#   let(:serializer) { serializer = UserSerializer.new(user) }
#   let(:builder) { Hal::Builder.new(serializer) }

#   it 'builds attributes' do
#     serializer.attributes = [:name, :email, :address]
#     build.build_attribute
#     expect(builder.resource.as_json).to equal({ name: 'Jane', email: 'jane@example.com', address: '123 main st.'})
#   end

#   it 'ignores attributes' do
#     serializer.attributes = [:name]
#     resource = build.build_resource
#     expect(builder.resource.as_json).to equal({ name: 'Jane'})
#   end

#   it 'overrides attributes' do
#     serializer.attributes = [:name, :age]
#     serializer.instance_eval do
#       def name
#         return 'foo'
#       end

#       def age
#         13
#       end
#     end
#     resource = build.build_resource
#     expect(builder.resource.as_json).to equal({ name: 'foo', age: 13 })
#   end
# end

# describe 'Builder when building relations' do
#   let(:user) { User.new('Jane', 'jane@example.com', '123 main st.') }
#   let(:serializer) { serializer = UserSerializer.new(user) }
#   let(:builder) { Hal::Builder.new(serializer) }

#   it 'attaches relation to the current context' do
#     expected = { '_links' :
#       self: {}
#     }
#     builder.curernt_context = '_links'
#     builder.add_relation :self
#     expect(builder.resource.as_json).to equal(expcted)
#   end

#   it 'passes params' do
#     expected = { '_links' :
#       self: { href: 'http://example.com', title: 'foo', templated: false }
#     }
#     builder.curernt_context = '_links'
#     builder.add_relation :self, href: 'http://example.com', title: 'foo', templated: false
#     expect(builder.resource.as_json).to equal(expcted)
#   end

#   describe 'relations' do
#     expected = {
#       '_links':
#         comments: [
#           { href: 'http://example.com/comments/1'},
#           { href: 'http://example.com/comments/2'}
#         ]
#     }

#     builder.curernt_context = '_links'
#     builder.add_relations :comments do
#     end
#   end

# end
