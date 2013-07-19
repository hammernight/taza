# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "taza/version"

Gem::Specification.new do |s|
  s.name                  = "taza"
  s.version               = Taza::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ["Adam Anderson", "Pedro Nascimento", "Oscar Rieken"]
  s.email                 = ["watir-general@googlegroups.com"]
  s.homepage              = "http://github.com/hammernight/taza"
  s.summary               = "Taza is a page object framework."
  s.description           = "Taza is a page object framework."
  s.required_ruby_version = '>= 1.8.7'
  s.rubyforge_project     = "taza"
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths         = ["lib"]

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "mocha", "~> 0.9.3"
  s.add_development_dependency "Selenium", "~> 1.1.14"
  s.add_development_dependency "firewatir", "~> 1.9.4"
  s.add_development_dependency "watir-webdriver", "~> 0.4"

  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "rspec", "~> 2.6"
  s.add_runtime_dependency "activesupport", "~> 3.1.0"
  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "rubigen", "~> 1.5.6"
  s.add_runtime_dependency "user-choices", "~> 1.1.6"

end
