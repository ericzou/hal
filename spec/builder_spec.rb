require 'spec_helper'

describe 'Builder basics' do
  let(:a_builder) { builder = Hal::Builder.new }
  let(:ASerializer) do
    Class.new { include Hal::Serializer}
  end

  before do
    a_builder.serializer = ASerializer.new
  end

  it 'defaults current context to root' do
    expect(a_builder.context).to equal(:root)
  end

  it 'by default creates an empty root resource' do
    resource = build.root_resource
    expect(resource.as_json).to equal({})
  end
end

describe 'Builder #resource' do
  let(:builder) { Hal::Builder.new }
  it 'returns the resource in curent context' do
    builder.curernt_context = :root
    expect(builder.resource).to equal(builder.root_resource)
  end
end

describe 'Builder when building attributes' do
  let(:user) { User.new('Jane', 'jane@example.com', '123 main st.') }
  let(:serializer) { serializer = UserSerializer.new(user) }
  let(:builder) { Hal::Builder.new(serializer) }

  it 'builds attributes' do
    serializer.attributes = [:name, :email, :address]
    build.build_attribute
    expect(builder.resource.as_json).to equal({ name: 'Jane', email: 'jane@example.com', address: '123 main st.'})
  end

  it 'ignores attributes' do
    serializer.attributes = [:name]
    resource = build.build_resource
    expect(builder.resource.as_json).to equal({ name: 'Jane'})
  end

  it 'overrides attributes' do
    serializer.attributes = [:name, :age]
    serializer.instance_eval do
      def name
        return 'foo'
      end

      def age
        13
      end
    end
    resource = build.build_resource
    expect(builder.resource.as_json).to equal({ name: 'foo', age: 13 })
  end
end

describe 'Builder when building relations' do
  let(:user) { User.new('Jane', 'jane@example.com', '123 main st.') }
  let(:serializer) { serializer = UserSerializer.new(user) }
  let(:builder) { Hal::Builder.new(serializer) }

  it 'attaches relation to the current context' do
    expected = { '_links' :
      self: {}
    }
    builder.curernt_context = '_links'
    builder.add_relation :self
    expect(builder.resource.as_json).to equal(expcted)
  end

  it 'passes params' do
    expected = { '_links' :
      self: { href: 'http://example.com', title: 'foo', templated: false }
    }
    builder.curernt_context = '_links'
    builder.add_relation :self, href: 'http://example.com', title: 'foo', templated: false
    expect(builder.resource.as_json).to equal(expcted)
  end

  describe 'relations' do
    expected = {
      '_links':
        comments: [
          { href: 'http://example.com/comments/1'},
          { href: 'http://example.com/comments/2'}
        ]
    }

    builder.curernt_context = '_links'
    builder.add_relations :comments do
    end
  end

end
