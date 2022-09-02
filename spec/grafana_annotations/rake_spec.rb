# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'grafana_annotations/rake'

describe GrafanaAnnotations::Rake::Task do
  subject(:invoke) { Rake::Task['sample_taks'].invoke }

  describe '#invoke' do
    let(:receiver) { double(:receiver) }

    before do
      allow(receiver).to receive(:call)
      Rake::Task.define_task(:sample_taks) do
        receiver.call
      end
    end

    after { Rake::Task.clear }

    context 'when configured' do
      let(:rake_tags) { %w[rfoo rbar] }
      let(:rake_text_prefix) { 'Sample Prefix' }
      before do
        GrafanaAnnotations.configure do |c|
          c.grafana_base_url 'http://foo/url'
          c.rake_tags rake_tags
          c.rake_text_prefix rake_text_prefix
        end

        allow(GrafanaAnnotations).to receive(:wrap) { |*_args, &block| block.call }
      end

      after do
        GrafanaAnnotations.instance_variable_set(:@config, nil)
      end

      it 'invoke task' do
        expect(receiver).to receive(:call).once
        invoke
      end

      it 'use wrapper' do
        expect(GrafanaAnnotations).to receive(:wrap).with(text: "#{rake_text_prefix} sample_taks", tags: rake_tags)
        invoke
      end
    end

    context 'when not configured' do
      it 'invoke task' do
        expect(receiver).to receive(:call).once
        invoke
      end

      it 'not use wrapper' do
        expect(GrafanaAnnotations).not_to receive(:wrap)
        invoke
      end
    end
  end
end
