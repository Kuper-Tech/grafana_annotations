# frozen_string_literal: true

require 'spec_helper'

describe GrafanaAnnotations::ApiClient do
  subject(:client) { described_class.new(base_url: base_url) }

  let(:base_url) { 'http://localhost:4242' }

  describe '#create' do
    let(:url) { base_url + '/api/annotations' }
    let(:annotation) do
      GrafanaAnnotations::Annotation.new(
        time: GrafanaAnnotations::Utils::Time.now_ms,
        tags: %w[stf rspec],
        text: 'Annotation Description'
      )
    end

    context 'when grafana returns successful response' do
      let(:response) do
        { 'message' => 'Annotation added', 'id' => 42 }
      end

      it 'returns success-monad wrapped annotation id' do
        WebMock.stub_request(:post, url)
               .with(body: annotation.to_json)
               .to_return(status: 200, body: response.to_json)

        result = client.create(annotation)
        expect(result).to be_success
        expect(result.value!).to eq(42)
      end
    end

    context 'when grafana returns an error' do
      it 'returns failure-monad wrapped error' do
        WebMock.stub_request(:post, url)
               .with(body: annotation.to_json)
               .to_return(status: 500, body: ':(')

        result = client.create(annotation)
        expect(result).to be_failure
        expect(result.failure).to eq(:http_error_500)
      end
    end
  end

  describe '#patch' do
    let(:annotation_id) { 42 }
    let(:url) { base_url + '/api/annotations/' + annotation_id.to_s }

    let(:params) do
      { timeEnd: GrafanaAnnotations::Utils::Time.now_ms + 600 * 1000 }
    end

    context 'when grafana returns successful response' do
      let(:response) do
        { 'message' => 'Annotation patched' }
      end

      it 'returns success-monad wrapped annotation id' do
        WebMock.stub_request(:patch, url)
               .with(body: params.to_json)
               .to_return(status: 200, body: response.to_json)

        result = client.patch(annotation_id, params)
        expect(result).to be_success
        expect(result.value!).to eq(42)
      end
    end

    context 'when request params are invalid' do
      it 'returns failure' do
        result = client.patch(annotation_id, foo: :bar)
        expect(result).to be_failure
        expect(result.failure).to eq(:empty_changeset)
      end
    end

    context 'when grafana returns an error' do
      it 'returns failure-monad wrapped error' do
        WebMock.stub_request(:patch, url).to_return(status: 500, body: '{}')

        result = client.patch(annotation_id, params)
        expect(result).to be_failure
        expect(result.failure).to eq(:http_error_500)
      end
    end
  end
end
