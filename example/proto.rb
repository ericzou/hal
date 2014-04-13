require 'pry'
require 'active_support/concern'
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/module/delegation"
require 'awesome_print'

module Hal

  def self.serialize(resource, options={})
    serializer = Hal.serializer_for(resource)
    options = { serializer: serializer }.merge(options)
    builder = Hal::Builder.new(options) do |builder|
      builder.add_attributes if serializer.respond_to?(:attributes)
      builder.add_links if serializer.respond_to?(:links)
      builder.add_embedded if serializer.respond_to?(:embedded)
    end
    builder.as_json
  end

  module Serializer
    extend ActiveSupport::Concern

    attr_accessor :builder

    def relation(name, options)
      builder.add_relation(name, options)
    end

    def relations(name, &block)
      builder.add_relations(name, &block)
    end

    def link(options)
      builder.add_link(options)
    end

    def resource(name, options={})
      builder.add_resource(name, options)
    end

    def resources(name, options={})
      builder.add_resources(name, options)
    end

  end

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

module Hal

  def self.serializer_for(resource)
    klass = (resource.class.to_s + 'Serializer').constantize
    klass.new(resource)
  end

  class Builder
    attr_accessor :serializer

    def initialize(options)
      @serializer = options.delete(:serializer)
      @root_node = options.delete(:root) || Hal::Node.new(type: :root)
      @current_node = options.delete(:current) || @root_node;
      @serializer.builder = self
      yield self
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
      current = @current_node
      begin
        node = Hal::Node.new(type: :relations, name: name)
        @current_node.add_child(node)
        @current_node = node

        objects = @serializer.instance_variable_get("@#{name}")
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
      node = Hal::Node.new(type: :resource, name: name)
      @current_node.add_child(node)
      current = @current_node
      begin
        @current_node = node
        Hal.serialize(resource, root: @root_node, current: @current_node)
      ensure
        @current_node = current
      end
    end

    def add_resources(name, options={})
      resources = @serializer.instance_variable_get("@#{name}")
      node = Hal::Node.new(type: :resources, name: name)
      @current_node.add_child(node)
      current = @current_node
      begin
        @current_node = node
        resources.each do |resource|
          Hal.serialize(resource, root: @root_node, current: @current_node)
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


# client code
require 'ostruct'
User = Class.new OpenStruct
Comment = Class.new OpenStruct
Account = Class.new OpenStruct

comments = [Comment.new(id: 1), Comment.new(id: 2)]
account = Account.new(id: 1)
user = User.new(comments: comments, account: account, name: 'mooo')

class UserSerializer
  include Hal::Serializer
  attr_accessor :user

  delegate :name, :email, to: :user

  def initialize(user)
    @user = user
    @account = user.account
    @comments = user.comments
  end


  def attributes
    [:name, :email, :title]
  end

  def title
    'title ' + @user.name
  end

  def links
    relation :account, href: "http://example.com/accounts/#{@account.id}"

    relations :comments do |comment|
      link href: "http://example.com/comments/#{comment.id}"
    end
  end

  def embedded
    resource :account
    resources :comments
  end
end

class AccountSerializer
  include Hal::Serializer
  attr_accessor :account

  delegate :id, to: :account

  def initialize(account)
    @account = account
  end

  def attributes
    [:id]
  end

  def links
    relation :self, href: "http://example.com/#{account.id}"
  end
end

class CommentSerializer
  include Hal::Serializer
  attr_accessor :comment

  delegate :id, to: :comment

  def initialize(comment)
    @comment = comment
  end

  def attributes
    [:id]
  end

  def links
    relation :self, href: "http://example.com/#{@comment.id}"
  end

end

if __FILE__ == $0
  data = Hal.serialize(user)
  puts "============", ap(data), "============"
end
