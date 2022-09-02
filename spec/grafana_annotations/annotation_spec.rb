# frozen_string_literal: true

require 'spec_helper'

describe GrafanaAnnotations::Annotation do
  let(:common_attributes) { { tags: %i[foo bar], text: 'foo message' } }

  describe ':time' do
    context 'when default' do
      let(:mock_time_now_ms) { 1_662_109_900_400 }
      before { allow(GrafanaAnnotations::Utils::Time).to receive(:now_ms).and_return(mock_time_now_ms) }

      it 'set Time.now in ms' do
        expect(described_class.new(common_attributes).time).to eq(mock_time_now_ms)
      end
    end

    context 'when specified' do
      let(:specified_time) { 1_662_109_900_900 }
      it 'set specified value' do
        expect(described_class.new(common_attributes.merge(time: specified_time)).time).to eq(specified_time)
      end
    end
  end
end
