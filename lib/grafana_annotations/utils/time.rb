# frozen_string_literal: true

module GrafanaAnnotations
  module Utils
    module Time
      def self.now_ms
        (::Time.now.to_f * 1000).to_i
      end
    end
  end
end
