require 'spec_helper'

describe Hal::Node do

  describe 'when initializes' do
    def new_node(options)
      Hal::Node.new(options)
    end

    it 'sets type' do
      expect(new_node(type: :foo).type).to be :foo
    end

    it 'sets name' do
      expect(new_node(name: :foo).name).to be :foo
    end

    it 'sets properties' do
      expect(new_node(properties: { foo: 'bar' }).properties).to eq({ foo: 'bar' })
    end
  end

  describe 'when as_json' do
    let(:node) { Hal::Node.new({}) }
    let(:first_child_node) { Hal::Node.new({}) }
    let(:second_child_node) { Hal::Node.new({}) }
    it 'attaches its properties' do
      node.properties = { foo: 'foo', bar: 'bar' }
      expect(node.as_json).to eq({ foo: 'foo', bar: 'bar' })
    end

    it 'attaches all children' do
      node.children = [first_child_node, second_child_node]
      expect(node).to receive(:attach_node).with(first_child_node).once
      expect(node).to receive(:attach_node).with(second_child_node).once
      node.as_json
    end
  end

  describe 'when attach_node with node name' do
    let(:parent) { Hal::Node.new({}) }
    let(:child) { Hal::Node.new(name: :foo, properties: { bar: 'bar' }) }
    before do
      parent.add_child(child)
    end

    it 'attach the node to hash with the name as key' do
      expect(parent.as_json).to eq({ foo: { bar: 'bar' } })
    end
  end

  describe 'when attach_node without node name' do
    let(:parent) { Hal::Node.new({}) }
    let(:child) { Hal::Node.new(properties: { bar: 'bar' }) }
    before do
      parent.add_child(child)
    end

    it 'attaches the node to an array' do
      expect(parent.as_json).to eq([{ bar: 'bar' }])
    end
  end

end