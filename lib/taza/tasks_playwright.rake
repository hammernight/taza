# Playwright helper tasks for installing the driver/browsers used by playwright-ruby-client

require 'rake'

namespace :playwright do
  desc 'Install Playwright browsers via npx (requires Node.js). Equivalent to: npx playwright install'
  task :install do
    sh "npx --version > /dev/null 2>&1 || (echo 'npx not found. Please install Node.js (https://nodejs.org/)'; exit 1)"
    sh 'npx playwright install'
  end

  namespace :install do
    desc 'Install Playwright via npm pinned to the compatible version and install browsers (requires Node.js and npm)'
    task :npm do
      version = nil
      begin
        require 'playwright'
        # playwright-ruby-client exposes the compatible CLI version
        version = Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.to_s.strip
      rescue LoadError
        # Fallback to latest if playwright-ruby-client is not available in this bundle
      end

      if version && !version.empty?
        sh "npm --version > /dev/null 2>&1 || (echo 'npm not found. Install Node.js (https://nodejs.org/)'; exit 1)"
        sh "npm install playwright@#{version} || npm install playwright@next"
      else
        sh "npm --version > /dev/null 2>&1 || (echo 'npm not found. Install Node.js (https://nodejs.org/)'; exit 1)"
        sh 'npm install playwright@latest'
      end
      sh './node_modules/.bin/playwright install'
    end
  end
end

