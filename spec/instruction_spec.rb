require 'spec_helper'

describe Hal::Instruction do
  let(:user) { User.new }
  let(:serializer) { UserSerializer.new(user) }
  let(:instruction) { Hal::Instruction.new(serializer: serializer, type: :resource) }

  it 'allows nested instructions' do
    child_one = Hal::Instruction.new(serializer: serializer, type: :links, parent: instruction)
    child_two = Hal::Instruction.new(serializer: serializer, type: :embedded, parent: instruction)
    expect(child_one.parent).to be instruction
    expect(child_two.parent).to be instruction
  end

  describe '#links' do
    before do
      serializer.instance_eval do
        @comments = factory_comments

        def comments
          @comments
        end

        def links
          relations :comments do |comment|
            link href: 'foo', title: 'bar'
          end
        end
      end

      @instruction =  Hal::Instruction.new(serializer: serializer, type: :resource)
    end

    it 'builds up set of nested links instructions' do
      # links
      expect(@instruction.children.length).to be 1
      links = @instruction.children.first
      expect(links).to be_kind_of Hal::Instruction
      expect(links.type).to be :links

      # relations
      expect(links.children.length).to be 1
      relations = links.children.first
      expect(relations.type).to be :relations
      expect(relations.name).to be :comments
      expect(relations.parent).to be links
      expect(relations.objects).to be serializer.comments

      # link
      expect(relations.children.length).to be 2
      link = relations.children.first
      expect(link.type).to be :link
      expect(link.params).to eql({ href: 'foo', title: 'bar' })
    end
  end

  describe '#embedded' do
    before do
      serializer.instance_eval do
        @comments = factory_comments
        @account = factory_account

        def comments
          @comments
        end

        def embedded
          resource :account
          resources :comments
        end
      end

      @instruction =  Hal::Instruction.new(serializer: serializer, type: :resource)
    end

    it 'builds up set of nested embedded instructions' do
      # embedded
      expect(@instruction.children.length).to be 1
      embedded = @instruction.children.first
      expect(embedded).to be_kind_of Hal::Instruction
      expect(embedded.type).to be :embedded

      # resource
      expect(embedded.children.length).to be 2
      resource = embedded.children.first
      expect(resource.type).to be :resource
      expect(resource.name).to be :account
      expect(resource.parent).to be embedded
      expect(resource.object).to be serializer.account

      # resources
      resources = embedded.children.last
      expect(resources.type).to be :resources
      expect(resources.name).to be :comments
      expect(resources.parent).to be embedded
      expect(resources.parent).to be embedded
      expect(resources.children.length).to be serializer.comments.length
      expect(resources.objects).to be serializer.comments
    end
  end
end