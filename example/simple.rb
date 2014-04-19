require 'hal'
require "active_support/core_ext/module/delegation"


class User < Struct.new(:name, :title, :id)
end

user = User.new('foo', 'Dr', 1)

class UserSerializer
  include Hal::Serializer
  attr_accessor :user

  delegate :name, :title, to: :user

  def initialize(user)
    @user = user
  end

  def attributes
    [:name, :title]
  end

  def links
    relation :self, { href: "http://yourapp.com/users/#{@user.id}" }
  end
end

if __FILE__ == $0
  json = Hal.json(user, pretty: true)
  puts "============", json, "============"
end
