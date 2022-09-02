# frozen_string_literal: true

require 'dry/struct'

require_relative 'grafana_annotations/version'
require_relative 'grafana_annotations/utils/time'

require_relative 'grafana_annotations/types'
require_relative 'grafana_annotations/config'
require_relative 'grafana_annotations/config/dsl'
require_relative 'grafana_annotations/annotation'
require_relative 'grafana_annotations/patch_annotation_request'
require_relative 'grafana_annotations/api_client'
require_relative 'grafana_annotations/wrap'

module GrafanaAnnotations
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class << self
    attr_reader :config
    include GrafanaAnnotations::Wrap

    def configure
      dsl = GrafanaAnnotations::Config::Dsl.new
      yield dsl
      @config = GrafanaAnnotations::Config.new(dsl.config)
    rescue StandardError => e
      raise ConfigurationError, e.message
    end

    def configured?
      config.is_a? GrafanaAnnotations::Config
    end

    def default_api_client
      @default_api_client ||= begin
        unless configured?
          raise ConfigurationError, 'Use GrafanaAnnotations.configure in initializer (see https://github.com/SberMarket-Tech/grafana_annotations#configuration)'
        end

        new_api_client({})
      end
    end

    def new_api_client(opts)
      return ApiClient.new(opts) unless configured?

      ApiClient.new(
        opts.merge(
          logger: config.logger,
          base_url: config.grafana_base_url,
          authorization: config.grafana_authorization
        )
      )
    end
  end
end
