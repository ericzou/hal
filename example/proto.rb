require "active_support/core_ext/module/delegation"
require 'awesome_print'
require 'ostruct'
require 'pry'
require_relative '../lib/hal'

User = Class.new OpenStruct
Comment = Class.new OpenStruct
Account = Class.new OpenStruct

user = author = User.new(name: 'John Smith', id: 2)
comments = [Comment.new(id: 1, author: author), Comment.new(id: 2, author: author)]
account = Account.new(id: 1)
user.account = account
user.comments = comments

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
    relation :account, href: "http://example.com/accounts/#{@account.id}" if @account

    if @comments
      relations :comments do |comment|
        link href: "http://example.com/comments/#{comment.id}"
      end
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
    @author = comment.author
  end

  def attributes
    [:id]
  end

  def links
    relation :self, href: "http://example.com/#{@comment.id}"
    relation :author, href: "http://example.com/users/#{@author.id}"
  end

  def embedded
    resource :author
  end

end

if __FILE__ == $0
  data = Hal.serialize(user)
  puts "============", ap(data), "============"
end
