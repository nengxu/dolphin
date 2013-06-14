# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dolphin/version'

Gem::Specification.new do |spec|
  spec.name          = "dolphin"
  spec.version       = Dolphin::VERSION
  spec.authors       = ["Neng Xu"]
  spec.email         = ["neng2.xu2@gmail.com"]
  spec.description   = %q{Dolphin: deploy smartly}
  spec.summary       = %q{Dolphin: deploy smartly}
  spec.homepage      = "https://github.com/nengxu/dolphin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "net-ssh"
  spec.add_dependency "parallel"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
