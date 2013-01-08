# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name               = 'to_source'
  s.version            = '0.2.10'
  s.authors            = ['Markus Schirp']
  s.email              = ['mbj@seonic.net']
  s.homepage           = 'http://github.com/mbj/to_source'
  s.summary            = %q{Transform Rubinius 1.9 AST back to equvalent source code.}
  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files   = %w[LICENSE README.md TODO]
  s.require_paths      = ['lib']

  s.add_dependency('adamantium',       '~> 0.0.3')
  s.add_dependency('equalizer',        '~> 0.0.2')
  s.add_dependency('abstract_type',    '~> 0.0.1')
  s.add_dependency('mutant-melbourne', '~> 2.0.3')
end
