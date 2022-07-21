# frozen_string_literal: true

module GrafanaAnnotations
  module Wrap
    def wrap(api_client: nil, text:, tags:, ok_tag: :ok, error_tag: :error) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return yield if GrafanaAnnotations.config.nil? && api_client.nil?

      api_client ||= GrafanaAnnotations.default_api_client
      res = api_client.create(time: Utils::Time.now_ms, tags: tags, text: text)
      maybe_log_result(res, 'sending grafana annotation')

      begin
        block_result = yield
        maybe_patch_annotation(api_client, res,
          text: "#{text} ok",
          tags: tags.push(ok_tag))

        block_result
      rescue StandardError => e
        maybe_patch_annotation(api_client, res,
          text: "#{text} #{e.class.name} #{e.message}",
          tags: tags.push(error_tag))

        raise
      end
    end

    private

    def maybe_patch_annotation(api_client, create_res, opts)
      return unless create_res.success?

      api_client.patch(create_res.value!, opts.merge(timeEnd: Utils::Time.now_ms)).tap do |result|
        maybe_log_result(
          result,
          "patching grafana annotation #{create_res.value!} with #{opts[:text]}"
        )
      end
    end

    def maybe_log_result(result, msg)
      return unless GrafanaAnnotations.config&.logger

      prefix = result.success? ? 'Ok' : 'Error'
      GrafanaAnnotations.config.logger.debug(
        [prefix, msg, result.failure].compact.join(' ')
      )
    end
  end
end
