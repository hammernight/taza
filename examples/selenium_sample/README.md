# Taza Selenium/WebDriver Sample (tiny)

This tiny example shows how to use Taza with Selenium WebDriver and the unified element API.

Prereqs
- Ruby 3+
- A browser installed (Chrome or Firefox)

Setup
```bash
cd examples/selenium_sample
bundle install
```

Run (optional)
- Note: This example navigates to a public URL. It’s meant as a local demo and isn’t part of the main test suite.
```bash
bundle exec rspec -fd
```

Files
- Gemfile: Pins rspec and uses Taza from the parent path; adds selenium-webdriver.
- spec/spec_helper.rb: requires Taza (selenium_webdriver provider is built-in).
- spec/selenium_sample_spec.rb: opens a session via Taza::Browser, navigates, and finds an element via the unified element API.

