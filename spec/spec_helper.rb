require 'pry'
require 'hal'

class UserSerializer
  include Hal::Serializer

  def initialize(user)
    @user = user
  end
end

class User
end

class Comment
end

class Account
end

def factory_comments
  first_comment = Comment.new
  second_comment = Comment.new
  [first_comment, second_comment]
end

def factory_account
  account = Account.new
end
