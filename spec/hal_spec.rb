require 'spec_helper'

describe 'an empty resource' do
  before do
    EmptySerializer = Class.new { include Hal::Serializer }
  end

  it "renders empty hash object" do
    expect(EmptySerializer.new.resource).to equal({})
  end
end


