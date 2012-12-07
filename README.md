to_source
=========

[![Build Status](https://secure.travis-ci.org/mbj/to_source.png?branch=master)](http://travis-ci.org/mbj/to_source)
[![Dependency Status](https://gemnasium.com/mbj/to_source.png)](https://gemnasium.com/mbj/to_source)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mbj/to_source)

Reverse parser to generate source code from the Rubinius AST. Also works well under MRI. 

Installation
------------

Install the gem ```to_source``` via your preferred method.

Examples
--------

```ruby
require 'to_source'
some_code = "a = 123"
ast = some_code.to_ast
# => #<Rubinius::AST::LocalVariableAssignment:0x21b8
        @value=#<Rubinius::AST::FixnumLiteral:0x21bc @value=123 @line=1>
        @variable=nil @line=1 @name=:a>
ast.to_source
# => "a = 123"
```

Credits
-------

* [Josep M. Bach (Txus)](http://txustice.me), [@txustice](http://twitter.com/txustice) on twitter
* [Markus Schirp (mbj)](https://github.com/mbj) [@_m_b_j_](http://twitter.com/_m_b_j_)

Contributing
-------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

Copyright (c) 2012 Josep M. Bach (Txus)
Copyright (c) 2012 Markus Schirp (mbj)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
