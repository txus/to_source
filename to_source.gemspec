# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'to_source'
  s.version     = '0.2.7'
  s.authors     = ['Josep M. Bach', 'Markus Schirp']
  s.email       = ['josep.m.bach@gmail.com', 'mbj@seonic.net']
  s.homepage    = 'http://github.com/txus/to_source'
  s.summary     = %q{Transform your Rubinius AST nodes back to source code. Reverse parsing!}
  s.description = %q{Transform your Rubinius AST nodes back to source code. Reverse parsing!}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency('adamantium',       '~> 0.0.3')
  s.add_dependency('mutant-melbourne', '~> 2.0.3')
end
