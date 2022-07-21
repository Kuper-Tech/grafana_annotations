# frozen_string_literal: true

module GrafanaAnnotations
  class Config
    class Dsl
      def initialize
        @config = {}
      end
      attr_reader :config

      %i[logger rake_tags grafana_base_url grafana_authorization rake_text_prefix].each do |meth|
        define_method(meth) do |value|
          @config[meth] = value
        end
      end

      def faraday_config(&block)
        @config[:faraday_config] = block
      end
    end
  end
end
