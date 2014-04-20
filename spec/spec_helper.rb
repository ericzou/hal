require 'pry'
require 'hal'

class ASerializer
  include Hal::Serializer
end

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

class CommentSerializer
end

class AccountSerializer
end

RSpec::Matchers.define :have_instance do |expected|
  match do |actual|
    if expected.is_a? Symbol
      !!actual.instance_variable_get("@#{expected}")
    else
      !!actual.instance_variables.detect do |var_name|
        actual.instance_variable_get(var_name) == expected
      end
    end
  end
end
