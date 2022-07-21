# GrafanaAnnotations

Add custom annotations to grafana from your ruby application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grafana_annotations', '~> 0.1.1'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install grafana_annotations

## Usage

### Configuration

```ruby
GrafanaAnnotations.configure do |c|
  # Logs requests and responses. Optional.
  c.logger Rails.logger

  # Tags for rake tasks instrumentation. Empty by default.
  c.rake_tags [:my_app, :rake]

  # Rake task annotation prefix
  c.rake_text_prefix 'Rake task'

  # URL to your grafana installation.
  c.grafana_base_url ENV.fetch('GRAFANA_URL')

  # Grafana authorization (i.e. `Bearer xxxxx`)
  c.grafana_authorization ENV.fetch('GRAFANA_AUTHZ')
end
```

### Creating annotations

```ruby
result = GrafanaAnnotations.default_api_client.create(
  time: GrafanaAnnotations::Utils::Time.now_ms, # timestamp in milliseconds (integer)
  tags: [:my_app, :my_event],
  text: "Boom!"
)
```

### Creating annotation span

`wrap` utility function creates an annotation when block starts executing and updates it with end time after.

```ruby
GrafanaAnnotations.wrap(text: 'something is happening', tags: [:my_app, :something]) do
  do_something()
end
```

### Rake tasks instrumentation

Just require `grafana_annotations/rake` within your Rakefile and annotation request will be sent for every rake task.
```ruby
# Rakefile
require 'grafana_annotations/rake'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Deployment

1. Update changelog and git add it
2.

```sh
bump2version patch --allow-dirty
```

3. git push && git push --tags
4. gem build
5. gem push grafana_annotations-x.x.x.gem
