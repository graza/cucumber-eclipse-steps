# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cucumber/eclipse/json_steps/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Graham Agnew"]
  gem.email         = ["graham.agnew@gmail.com"]
  gem.description   = <<-EOS
    This is a Cucumber formatter gem that outputs the step definitions and steps
    such that the cucumber.eclipse.steps.json Eclipse plugin can know where
    the steps are defined.
  EOS
  gem.summary       = %q{Stepdef/step JSON formatter for cucumber-eclipse.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cucumber-eclipse-json_steps"
  gem.require_paths = ["lib"]
  gem.version       = Cucumber::Eclipse::JsonSteps::VERSION
end
