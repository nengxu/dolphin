# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dolphin/version'

Gem::Specification.new do |spec|
  spec.name          = "dolphin"
  spec.version       = Dolphin::VERSION
  spec.authors       = ["Neng Xu"]
  spec.email         = ["neng2.xu2@gmail.com"]
  spec.homepage      = "https://github.com/nengxu/dolphin"
  spec.license       = "MIT"

  spec.description   = %q{Dolphin: deploy agilely like dolphins can swim. A multi-threaded multi-stage deployment tool utilizes the full power of Git and Ruby.}
  spec.summary       = %q{Dolphin: deploy agilely like dolphins can swim. A multi-threaded multi-stage deployment tool utilizes the full power of Git and Ruby.
    Bye bye, serial iteration over list of servers;
    Welcome, multi-threaded deployment using Parallel gem.
    Bye bye, afterthought of the multistage extension;
    Welcome, multi-stage deployment built in from inception.
    Bye bye, SVN style checkout directories on servers;
    Welcome, git repository on servers.
    Bye bye, Capistrano style symlink tricks for current / rollback;
    Welcome, git checkout.
    Bye bye, Rake tasks;
    Welcome, Thor actions.
    Bye bye, complexity;
    Welcome, nimbleness.
  }

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
