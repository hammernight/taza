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
  s.summary               = "Taza is an opinionated page object framework."
  s.description           = "Taza is an opinionated page object framework."
  s.required_ruby_version = '>= 3.0.0'
  s.rubyforge_project     = "taza"
  s.files                 = `git ls-files lib bin History.txt README.md`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths         = ["lib"]

  s.add_runtime_dependency(%q<user-choices>, ["~> 1.1.0"])
  s.add_runtime_dependency(%q<Selenium>, ["~> 1.1.0"])
  s.add_runtime_dependency(%q<watir>, ["~> 7.3.0"])
  s.add_runtime_dependency(%q<activesupport>, [">= 7.1.0"])
  s.add_runtime_dependency(%q<thor>, ["~> 1.3.0"])

  s.add_development_dependency(%q<mocha>, ["~> 2.7.0"])
  s.add_development_dependency(%q<rake>, ["~> 13.2.0"])
  s.add_development_dependency(%q<rspec>, ["~> 3.13.0"])
end
