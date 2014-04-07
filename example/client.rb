module HalResponder
  def to_json
    serializer = Hal.serializer_for(resource)
    instruction = Instruction.new(serializer)
    hal_resource = Hal::Builder.new(instruction)
    hal_resource.to_json
  end
end
