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
  s.required_ruby_version = '>= 2.0.0'
  s.rubyforge_project     = "taza"
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths         = ["lib"]

  s.add_runtime_dependency(%q<rake>, [">= 0.9.2"])
  s.add_runtime_dependency(%q<mocha>, [">= 0.9.3"])
  s.add_runtime_dependency(%q<user-choices>, ["~> 1.1.6.1"])
  s.add_runtime_dependency(%q<Selenium>, ["~> 1.1.14"])
  s.add_runtime_dependency(%q<firewatir>, ["~> 1.9.4"])
  s.add_runtime_dependency(%q<watir-webdriver>, ["~> 0.4"])
  s.add_runtime_dependency(%q<watir>, ["~> 5.0.0"])
  s.add_runtime_dependency(%q<activesupport>, [">= 3.2.0"])
  s.add_runtime_dependency(%q<thor>, [">= 0.18.1"])
  s.add_runtime_dependency(%q<rspec>, ["~> 3.0"])
end
