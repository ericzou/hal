require "active_support/core_ext/module/delegation"
require 'hal'

class UserSerializer
  include Hal::Serializer

  delegate :name, :title to: :user

  def initialize(user)
    @user = user
  end

  def attributes
    [:name, :title, ]
  end

  def links
    relation :self, "http://yourapp.com/users/#{@user.id}"
  end
end

if __FILE__ == $0
  json = Hal.serialize(user).to_json
  ap "============"
  ap json
  ap "============"
end
