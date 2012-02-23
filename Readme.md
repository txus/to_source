# to_source [![Build Status](https://secure.travis-ci.org/txus/to_source.png)](http://travis-ci.org/txus/to_source)

to_source is a little Rubinius gem that enables Abstract Syntax Tree nodes to
transform themselves into source code. It's the reverse of Rubinius' builtin
`#to_ast` method. See for yourself:

    #!/bin/rbx
    some_code = "a = 123"
    ast = some_code.to_ast
    # => #<Rubinius::AST::LocalVariableAssignment:0x21b8
            @value=#<Rubinius::AST::FixnumLiteral:0x21bc @value=123 @line=1>
            @variable=nil @line=1 @name=:a>

    ast.to_source
    # => "a = 123"

## WIP!

It's a work in progress, not yet released. Watch the project to get noticed
about its progress :)

## Installing

Put this in your Gemfile:

    gem 'to_source'

And just call `#to_source` in any AST node!

## Who's this

This was made by [Josep M. Bach (Txus)](http://txustice.me) under the MIT
license. I'm [@txustice](http://twitter.com/txustice) on twitter (where you
should probably follow me!).
