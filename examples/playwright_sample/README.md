# Taza Playwright Sample (tiny)

This tiny example shows how to use Taza with Playwright and the unified element API.

Prereqs
- Ruby 3+
- Chrome/Chromium installed (or Playwright browsers installed)

Setup
```bash
cd examples/playwright_sample
bundle install
```

Run (optional)
- Note: This example navigates to a public URL. It’s meant as a local demo and isn’t part of the main test suite.
```bash
bundle exec rspec -fd
```

Files
- Gemfile: Pins rspec and uses Taza from the parent path; adds playwright-ruby-client.
- spec/spec_helper.rb: requires Taza and the Playwright adapter.
- spec/playwright_sample_spec.rb: opens a session via Taza::Browser, navigates, and finds an element via the unified element API.

