module HstoreAccessor
  module Serialization

    InvalidDataTypeError = Class.new(StandardError)

    VALID_TYPES = [:string, :integer, :float, :time, :boolean, :array, :hash, :date, :decimal]

    SEPARATOR = "||;||"

    DEFAULT_SERIALIZER = ->(value) { value.to_s }
    DEFAULT_DESERIALIZER = DEFAULT_SERIALIZER

    SERIALIZERS = {
      array:    -> value { (value && value.join(SEPARATOR)) || nil },
      hash:     -> value { (value && value.to_json) || nil },
      time:     -> value { value.to_i },
      boolean:  -> value { (value.to_s == "true").to_s },
      date:     -> value { (value && value.to_s) || nil }
    }

    DESERIALIZERS = {
      array:    -> value { (value && value.split(SEPARATOR)) || nil },
      hash:     -> value { (value && JSON.parse(value)) || nil },
      integer:  -> value { value.to_i },
      float:    -> value { value.to_f },
      time:     -> value { Time.at(value.to_i) },
      boolean:  -> value { TypeHelpers.cast(:boolean, value) },
      date:     -> value { (value && Date.parse(value)) || nil },
      decimal:  -> value { BigDecimal.new(value) }
    }

    def serialize(type, value, serializer=nil)
      return nil if value.nil?
      serializer ||= (SERIALIZERS[type] || DEFAULT_SERIALIZER)
      serializer.call(value)
    end

    def deserialize(type, value, deserializer=nil)
      return default_value_for(type) if value.nil?
      deserializer ||= (DESERIALIZERS[type] || DEFAULT_DESERIALIZER)
      deserializer.call(value)
    end
    
    def default_value_for(type)
      case type
      when :array
        return []
      when :hash
        return {}
      else
        return nil
      end 
    end

  end
end
