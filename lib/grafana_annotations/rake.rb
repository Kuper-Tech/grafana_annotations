# frozen_string_literal: true

module GrafanaAnnotations
  module Rake
    module Task
      def invoke(*args)
        return super unless GrafanaAnnotations.configured?

        text = [GrafanaAnnotations.config.rake_text_prefix, name].join(' ')
        text += " #{args.inspect}" unless args.empty?

        ::GrafanaAnnotations.wrap(text: text, tags: GrafanaAnnotations.config.rake_tags) do
          super
        end
      end
    end
  end
end

module Rake
  class Task
    prepend(::GrafanaAnnotations::Rake::Task)
  end
end
