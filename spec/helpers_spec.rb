require 'spec_helper'

describe 'this is a test' do
  it 'should pass' do
    expect(1 + 2).to eq(3)
  end
end


class User
  include Hal

  attributes :name, :email
end
