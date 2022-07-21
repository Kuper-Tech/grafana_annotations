# frozen_string_literal: true

require 'logger'
require 'dry/monads/result'
require 'dry/initializer'
require 'faraday'
require 'json'

module GrafanaAnnotations
  #
  # Implements Grafana annotations API client
  # https://grafana.com/docs/grafana/latest/developers/http_api/annotations
  #
  class ApiClient
    include Dry::Monads::Result::Mixin
    extend Dry::Initializer

    option :base_url
    option :authorization, default: proc { nil }
    option :logger, default: proc { nil }

    # @param [Annotation,Hash] annotation
    # @return [Success<Integer>, Failure<Symbol>]
    def create(annotation)
      annotation = GrafanaAnnotations::Annotation.new(annotation)

      result = with_error_handler { connection.post('/api/annotations', annotation.to_json) }
      result.bind do |resp|
        parse_json_body(resp.body).bind do |resp_body|
          annotation_id = resp_body['id']
          annotation_id = nil if annotation_id == ''

          annotation_id ? Success(annotation_id) : Failure(:invalid_response_format)
        end
      end
    end

    # @param [Integer] id
    # @param [Hash] params
    # @return [Success<Integer>, Failure<Symbol>]
    def patch(id, params)
      result = with_error_handler do
        struct = PatchAnnotationRequest.new(params)
        return Failure(:empty_changeset) if struct.to_h.empty?

        connection.patch("/api/annotations/#{id}", struct.to_h.to_json)
      end

      result.bind { Success(id) }
    end

    private

    def parse_json_body(body)
      Success(JSON.parse(body))
    rescue JSON::ParseError
      Failure(:invalid_response_format)
    end

    def with_error_handler
      resp = yield
      return Failure(:"http_error_#{resp.status}") unless resp.success?

      Success(resp)
    rescue Faraday::ParsingError => e
      Failure(:"http_error_#{e.response&.status}")
    rescue Faraday::TimeoutError
      Failure(:timeout)
    rescue Faraday::ConnectionFailed
      Failure(:connection_failed)
    end

    def connection
      @connection ||= Faraday.new(url: base_url, headers: headers) do |conn|
        conn.response :logger, logger, headers: logger.debug?, bodies: logger.debug? if logger
      end
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => authorization
      }.compact
    end
  end
end
