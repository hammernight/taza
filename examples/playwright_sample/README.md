# Taza Playwright Sample (tiny)

This tiny example shows how to use Taza with Playwright and the unified element API.

Prereqs
- Ruby 3+
- Node.js 18+ (required by Playwright CLI)
- Chrome/Chromium installed (or install Playwright browsers via CLI)

Setup
```bash
cd examples/playwright_sample
bundle install
# Install Playwright CLI + browsers (pick one)
# 1) Simple (uses npx)
npx playwright install
# or 2) Faster for CI (pins to the gem-compatible version)
export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
npm install playwright@$PLAYWRIGHT_CLI_VERSION || npm install playwright@next
./node_modules/.bin/playwright install
# or 3) Using the repo rake task (from project root)
cd ../..
bundle exec rake -f lib/taza/tasks_playwright.rake playwright:install
cd examples/playwright_sample
```

Notes
- Taza’s Playwright provider will use the CLI at PLAYWRIGHT_CLI_EXECUTABLE_PATH if set, otherwise it defaults to "npx playwright".
- You can set: `export PLAYWRIGHT_CLI_EXECUTABLE_PATH="./node_modules/.bin/playwright"` to use the npm-installed CLI.

Run
```bash
bundle exec rspec -fd
```

CI (GitHub Actions)
- Ensure Node is installed, then run `npx playwright install` before the specs.
- See .github/workflows/examples.yml for a working job definition.

Files
- Gemfile: Pins rspec and uses Taza from the parent path; adds playwright-ruby-client.
- spec/spec_helper.rb: requires Taza and the Playwright adapter.
- spec/playwright_sample_spec.rb: opens a session via Taza::Browser, navigates, and finds an element via the unified element API.
