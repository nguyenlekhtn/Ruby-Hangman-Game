# frozen_string_literal: true

require 'yaml'

# mixin
module BasicSerializable
  # should point to a class; change to a different
  # class (e.g. MessagePack, JSON, YAML) to get a different
  # serialization
  # serializer = YAML

  def serialize(serializer)
    obj = {}
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    serializer.dump obj
  end

  def unserialize(serializer:, string:, is_file: false)
    obj = is_file ? serializer.load_file(string) : @serializer.load(string)
    obj.each_key do |key|
      instance_variable_set(key, obj[key])
    end
  end
end
