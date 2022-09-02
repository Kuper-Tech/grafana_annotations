# frozen_string_literal: true

require 'spec_helper'

describe GrafanaAnnotations do
  include Dry::Monads::Result::Mixin

  describe '#configured?' do
    context 'when configured' do
      before do
        GrafanaAnnotations.configure do |c|
          c.grafana_base_url 'http://foo/url'
        end
      end

      after { GrafanaAnnotations.instance_variable_set(:@config, nil) }

      it 'return ture' do
        expect(GrafanaAnnotations.configured?).to be_truthy
      end
    end

    context 'when not configured' do
      it 'return false' do
        expect(GrafanaAnnotations.configured?).to be_falsey
      end
    end
  end

  describe '#wrap' do
    context 'with custom api client' do
      let(:api_client) { GrafanaAnnotations::ApiClient.new(base_url: 'https://localhost:9091') }

      it 'does not use default client' do
        expect(described_class).not_to receive(:default_api_client)
        expect(api_client).to receive(:create).and_return(Success(42))
        expect(api_client).to receive(:patch).and_return(Success(42))

        result = described_class.wrap(api_client: api_client, text: 'foobar', tags: ['foo']) { 42 }
        expect(result).to eq(42)
      end
    end

    context 'with default api client' do
      context 'when annotations are not configured' do
        it 'does nothing' do
          result = described_class.wrap(tags: ['foo'], text: 'foobar') { 42 }
          expect(result).to eq(42)
        end
      end

      context 'when annotations are configured' do
        let(:api_client) { described_class.default_api_client }

        before do
          described_class.configure do |config|
            config.grafana_base_url 'https://localhost:9091'
          end
        end

        after do
          described_class.instance_variable_set(:@config, nil)
        end

        context 'when initial annotation succeeds' do
          it 'patches original annotation' do
            expect(api_client).to receive(:create)
              .with(hash_including(tags: ['foo'], text: 'foobar'))
              .and_return(Success(42))

            expect(api_client).to receive(:patch)
              .with(42, hash_including(text: 'foobar ok'))
              .and_return(Success(42))

            result = described_class.wrap(text: 'foobar', tags: ['foo']) { 42 }
            expect(result).to eq(42)
          end
        end

        context 'when given block fails' do
          it 'adds error tag' do
            expect(api_client).to receive(:create).and_return(Success(42))

            expect(api_client).to receive(:patch)
              .with(42, hash_including(tags: %i[foo error], text: 'text RuntimeError boom'))
              .and_return(Success(42))

            expect do
              described_class.wrap(text: 'text', tags: [:foo]) { raise('boom') }
            end.to raise_error(RuntimeError, 'boom')
          end
        end

        context 'when initial annotation fails' do
          it 'does not send patch request' do
            expect(api_client).to receive(:create).and_return(Failure(:http_error_503))
            expect(api_client).not_to receive(:patch)

            result = described_class.wrap(text: 'foobar', tags: ['foo']) { 42 }
            expect(result).to eq(42)
          end
        end
      end
    end
  end
end
