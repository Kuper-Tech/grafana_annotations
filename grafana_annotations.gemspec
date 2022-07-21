# frozen_string_literal: true

require_relative 'lib/grafana_annotations/version'

Gem::Specification.new do |spec|
  spec.name          = 'grafana_annotations'
  spec.version       = GrafanaAnnotations::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['SberMarket Team']
  spec.email         = ['nikita.babushkin@sbermarket.ru']

  spec.summary       = 'Utilities for creating grafana annotations from your ruby application.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/SberMarket-Tech/grafana_annotations'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/SberMarket-Tech/grafana_annotations'
  spec.metadata['changelog_uri'] = 'https://github.com/SberMarket-Tech/grafana_annotations/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rubocop', '~> 0.81'
end
