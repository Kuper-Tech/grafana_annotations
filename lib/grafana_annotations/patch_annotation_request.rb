# frozen_string_literal: true

module GrafanaAnnotations
  class PatchAnnotationRequest < Dry::Struct
    attribute? :time, Types::Strict::Integer
    attribute? :timeEnd, Types::Strict::Integer
    attribute? :tags, Types::Strict::Array.of(Types::Coercible::String)
    attribute? :text, Types::Strict::String
  end
end
