# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'passauce/version'

Gem::Specification.new do |gem|
  gem.name          = "passauce"
  gem.version       = Passauce::VERSION
  gem.authors       = ["Pierce Schmerge"]
  gem.email         = ["pschmerg@nearinfinity.com"]
  gem.description   = "passbook gem" 
  gem.summary       = "passbook summary" 
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency 'rubyzip'
end
