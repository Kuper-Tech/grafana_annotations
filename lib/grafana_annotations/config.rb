# frozen_string_literal: true

module GrafanaAnnotations
  class Config < Dry::Struct
    attribute(:grafana_base_url, Types::Strict::String)
    attribute?(:grafana_authorization, Types::Strict::String.optional)
    attribute(:logger, Types::Nominal::Any.default { Logger.new(IO::NULL) })
    attribute(:faraday_config, Types::Nominal::Any.default { ->(_c) {} })
    attribute(:rake_tags, Types::Strict::Array.of(Types::Coercible::String).default { [] })
    attribute(:rake_text_prefix, Types::Strict::String.default('Rake task'))
  end
end
