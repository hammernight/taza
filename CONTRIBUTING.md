# Contributing to Taza

Thanks for helping make Taza better! This guide covers local setup, running tests, and a checklist for adding/maintaining adapters.

## Local development

Prereqs
- Ruby 3.0+ (we test across 3.0–3.3 and JRuby)
- Bundler

Setup
```bash
# from repo root
bundle install
```

Run all tests
```bash
bundle exec rspec -fd --no-color
```

Run a subset
```bash
# a single spec file
bundle exec rspec spec/taza/browser_spec.rb -fd

# a single example by description
bundle exec rspec spec/taza/browser_spec.rb -e "should use params"
```

Examples (optional)
- Playwright sample
```bash
cd examples/playwright_sample
bundle install
bundle exec rspec -fd
```
- Selenium/WebDriver sample
```bash
cd examples/selenium_sample
bundle install
bundle exec rspec -fd
```
- Custom adapter sample
```bash
cd examples/custom_adapter
bundle install
bundle exec rspec -fd
```

## Running and filtering tests

Rake tasks (by site / tag)
- You can filter specs by site folder and RSpec tags via ENV:

```bash
# run only specs under spec/<any>/**/<site_name>/**
SITE=foo_site bundle exec rake spec

# run only specs tagged with @smoke (RSpec metadata :smoke)
TAGS=smoke bundle exec rake spec

# combine: run smoke tests for a given site
SITE=foo_site TAGS=smoke bundle exec rake spec
```

RSpec CLI (direct)
- You can also use rspec patterns and tags directly:

```bash
bundle exec rspec spec/sites/foo_site -t smoke -fd
```

## Adding or updating an adapter (checklist)

Minimum contract
- Build path: put your adapter at `lib/taza/drivers/<name>.rb` and register it.
- Registration: `Taza::Browser.register(:<name>) { |params| Taza::Drivers::<YourClass>.build(params) }`
- Builder: `.build(params) => Taza::Browser::Session`
  - Must return a `Taza::Browser::Session.new(raw, goto_proc:, close_proc:)`
  - `goto_proc` must navigate to the URL using the native API
  - `close_proc` must dispose native resources in a safe order

Options and validation
- Supported common keys: `driver`, `browser`, `headless`, and `extra` (Hash)
- Taza’s core will coerce/validate some options; prefer:
  - `browser` as a Symbol (e.g., `:chrome`, `:firefox`, `:chromium`)
  - `headless` as a boolean (true/false)
- Your adapter may read additional keys from `params` as needed

Error model
- Don’t swallow exceptions in `goto` or `close`; let them bubble
- Taza will normalize common exceptions to `Taza::Errors::{TimeoutError, ElementNotFound, StaleElement, DialogError, NavigationError}`
  - We already recognize common Selenium & Watir classes; message-based fallbacks apply for others

Events (optional but encouraged)
- Bridge native events to `Taza::Events` where practical
  - Common event names:
    - `:console` — `{ session:, message }`
    - `:dialog_open` — `{ session:, dialog }`
    - `:request` — `{ session:, request }`
    - `:response` — `{ session:, response }`

Unified Element API (optional)
- Taza ships a thin element facade (`Taza::Elements`)
- If your `raw` object supports one of these, unified lookups will work out-of-the-box:
  - `raw.element(**locator)` (Watir-style)
  - `raw.find_element(by, value)` (Selenium-style)
  - `raw.locator(selector)` or `raw.query_selector(selector)` (Playwright-style)
- If none match, consider exposing a compatible method or document how users can access raw elements in blocks

Tests
- Add adapter tests that prove:
  - Session is returned and delegates goto/close
  - Goto is invoked with the provided URL
  - Close tears down the driver in the right order
  - (Optional) Events are bridged (console/dialog/network)
- You can use the shared adapter contract examples by generating a skeleton:
  - `taza adapter <name>` (see the generated `spec/support/shared_adapter_contract.rb`)

Documentation
- Update `BROWSERS.md` if adding a built-in adapter
- If shipping an external adapter gem, include a README with:
  - Installation & require (`require 'taza/drivers/<name>'`)
  - Configuration keys
  - Minimal example

Examples and CI (nice-to-have)
- Consider adding a tiny example under `examples/<name>_sample` with a Gemfile and 1–2 specs
- Optionally add a CI smoke job (allowed to fail) to detect integration drift early

## Code style & commit tips
- Keep changes focused; add tests when changing behavior
- Prefer small, incremental commits
- Ensure `bundle exec rspec` is green before pushing

## Filing issues
- Include Ruby version and driver versions
- Share a minimal repro when possible
- Paste failure messages and relevant stack traces

Thanks again for helping improve Taza!
