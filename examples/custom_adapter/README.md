# Taza Custom Adapter Sample (tiny)

This tiny example shows a minimal adapter that registers a new driver (:acme) and uses the unified element API.

Prereqs
- Ruby 3+

Setup
```bash
cd examples/custom_adapter
bundle install
```

Run (optional)
```bash
bundle exec rspec -fd
```

Files
- Gemfile: Pins rspec and uses Taza from the parent path.
- support/acme_adapter.rb: implements and registers a tiny adapter.
- spec/spec_helper.rb: requires Taza and the custom adapter.
- spec/custom_adapter_spec.rb: builds a session with :acme, calls goto, and finds an element via the unified element API.

