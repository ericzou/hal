require 'spec_helper'

describe Hal::Serializer do
  let(:user) { User.new }
  let(:serializer) { UserSerializer.new(user) }

  it 'provides a set of DSLs' do
    [:relations, :relation, :link, :resource, :resources].each do |method|
      expect(serializer.respond_to?(method)).to be_true
    end
  end

  it 'creates a default resource instruction' do
    expect(serializer.instruction).to be_kind_of(Hal::Instruction)
    expect(serializer.instruction.type).to be(:resource)
  end

  # describe '#links' do
  #   it 'returns instruction for links' do
  #     instruction = serializer.links
  #     expect(instruction.type).to equal(:links)
  #   end
  #   it 'contains object' do
  #     expect(instruction.object).to equal(user)
  #   end
  # end

  describe '#link' do
    let(:instruction) { serializer.link(href: 'http://example.com/users/1', title: 'Mike') }
    it 'returns an instruction' do
      expect(instruction.class).to equal(Hal::Instruction)
    end
    it 'has the link as type' do
      expect(instruction.type).to equal(:link)
    end
    it 'pass params' do
      expect(instruction.params).to equal({href: 'http://example.com/users/1', title: 'Mike'})
    end
    it 'contains object' do
      expect(instruction.object).to equal(user)
    end
  end

  describe '#relation' do
    let(:instruction) { serializer.relation(:author, href: 'http://example.com/users/2', title: 'Arthur') }
    it 'returns an instruction' do
      expect(instruction.class).to equal(Hal::Instruction)
    end
    it 'has type as relation' do
      expect(instruction.type).to equal(:relation)
    end
    it 'has name' do
      expect(instruction.name).to equal(:author)
    end
    it 'has params' do
      expect(instruction.params).to equal({href: 'http://example.com/users/2', title: 'Arthur'})
    end
    it 'contains object' do
      expect(instruction.object).to equal(user)
    end
  end

  describe '#relations' do
    let(:instruction) do
      serializer.relations :comments do |comment|
        link href: 'http://example.com/comments/1', title: 'first comment'
        link href: 'http://example.com/comments/2', title: 'second comment'
      end
    end
    before do
      serializer.comments = factory_comments
    end
    it 'returns an instruction' do
      expect(instruction.class).to equal(Hal::Instruction)
    end
    it 'has type as relations' do
      expect(instruction.type).to equal(:relations)
    end
    it 'has name' do
      expect(instruction.name).to equal(:comments)
    end
    it 'has objects' do
      expect(instruction.objects).to equal(serializer.comments)
    end

    describe 'nested instructions' do
      let(:instructions) { instruction.instructions }
      let(:first_nested_instruction) { instruction.instructions }
      specify { expect(instructions.length).to_be 2 }
      it 'has types' do
        expect(first_nested_instruction.type).to equal(:link)
      end
      it 'has params' do
        expect(first_nested_instruction.params).to equal({ href: 'http://example.com/comments/1', title: 'first comment' })
      end
      it 'has object' do
        expect(first_nested_instruction.object).to equal(first_comment)
      end
    end
  end

  describe '#embedded' do
    let(:instruction) { serializer.embedded }
    it 'returns an instruction' do
      expect(instruction.class).to equal(Hal::Instruction)
    end
    it 'has type as embedded' do
      expect(instruction.type).to equal(:embedded)
    end
    it 'has object' do
      expect(instruction.object).to equal(user)
    end
  end

  describe '#resource' do
    let(:instruction) { serializer.resource :account }
    before do
      serializer.account = factory_account
    end
    it 'returns an instruction' do
      expect(instruction.class).to equal(Hal::Instruction)
    end
    it 'has type as resource' do
      expect(instruction.type).to equal(:resource)
    end
    it 'has object' do
      expect(instruction.object).to equal(serializer.account)
    end
  end

  describe '#resources' do
    let(:instruction) { serializer.resources :comments }
    before do
      serializer.comments = factory_comments
    end
    it 'returns an instruction' do
      expect(instruction.class).to equal(Hal::Instruction)
    end
    it 'has type as resources' do
      expect(instruction.type).to equal(:resources)
    end
    it 'has objects' do
      expect(instruction.objects).to equal(serializer.comments)
    end
  end
end

# builder .build(:links, ctx)
# builder .build(:resource, :comment_thread, each_serializer: CommentThreadSerializer)
# builder .build(:relation, :comment_thread, each_serializer: CommentThreadSerializer)
# instructs
