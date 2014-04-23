require 'pry'
require 'hal'

class ASerializer
  include Hal::Serializer
end

module Helpers
  def assigns(builder, name)
    builder.instance_variable_get("@#{name}")
  end

  def first_child_node_of_type(node, type)
    node.children.detect{ |node| node.type == type }
  end

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

RSpec.configure do |config|
  config.include(Helpers)
end