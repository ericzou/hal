$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "hal"
  s.version     = '0.01'
  s.authors     = ["Eric Zou"]
  s.email       = ["hello@ericzou.com"]
  s.homepage    = "https://github.com/ericzou/hal"
  s.summary     = %q{A simple Ruby Library for building hypertext application language(HAL).}
  s.description = %q{A simple Ruby Library for building hypertext application language(HAL).}
  s.license     = "MIT"

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'multi_json'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'kicker'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'awesome_print'

  s.files         = `git ls-files`.split("\n")
end
