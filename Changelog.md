# v0.3.0 2013-01-4

* [Changed] Rewrote internals compleatly
* [fixed] Emit indentation of complex nested structures with rescue statements correctly

# v0.2.9 2013-01-4

* [fixed] Handle regexp literals containing slashes in non shash delimiters %r(/) correctly

[Compare v0.2.8..v0.2.9](https://github.com/mbj/to_source/compare/v0.2.8...v0.2.9)

# v0.2.8 2013-01-3

* [Changed] Emit many times more ugly code, but correctnes > beautifulnes
* [fixed] Emit break with parantheses
* [fixed] Emit op assign and as "&&="
* [fixed] Emit op assign or as "||="

[Compare v0.2.7..v0.2.8](https://github.com/mbj/to_source/compare/v0.2.7...v0.2.8)

# v0.2.7 2013-01-2

* [fixed] Emit super with blocks correctly

[Compare v0.2.6..v0.2.7](https://github.com/mbj/to_source/compare/v0.2.6...v0.2.7)

# v0.2.6 2013-01-1

* [fixed] Emit super vs super() correctly

[Compare v0.2.5..v0.2.6](https://github.com/mbj/to_source/compare/v0.2.5...v0.2.6)

# v0.2.5 2012-12-14

* [fixed] Emit unary operators correctly
* [fixed] Define with optional splat and block argument
* [fixed] Emit arguments to break keyword
* [change] Uglify output of binary operators with unneded paranteses. Correct output > nice output.
* [fixed] Emit nested binary operators correctly.
* [fixed] Emit element reference on self correctly. self[foo].

[Compare v0.2.4..v0.2.5](https://github.com/mbj/to_source/compare/v0.2.4...v0.2.5)

# v0.2.4 2012-12-07

* [feature] Allow to emit pattern variables as root node
* [fixed] Emit send with splat and block argument correctly

[Compare v0.2.3..v0.2.4](https://github.com/mbj/to_source/compare/v0.2.3...v0.2.4)

# v0.2.3 2012-12-07

* [fixed] Nuke dangling require  (sorry for not running specs after gemspec change)

[Compare v0.2.2..v0.2.3](https://github.com/mbj/to_source/compare/v0.2.2...v0.2.3)

# v0.2.2 2012-12-07

* [fixed] Emit of pattern arguments with no formal arguments present
* [fixed] Missed to require set

[Compare v0.2.1..v0.2.2](https://github.com/mbj/to_source/compare/v0.2.1...v0.2.2)

# v0.2.1 2012-12-07

* [fixed] Emit of def on splat with block
* [fixed] Emit of pattern args 

[Compare v0.2.0..v0.2.1](https://github.com/mbj/to_source/compare/v0.2.0...v0.2.1)

# v0.2.0 2012-12-07

* [BRAKING CHANGE] Remove core extension Rubinius::AST::Node#to_source (mbj)
* [feature] Add support for MRI via melbourne gem (mbj)
* [fixed] 100% Yard covered documentation (mbj)
* [fixed] Emit most binary operators without parantheses (mbj)
* [feature] Port tests to rspec2 and greatly improve coverage and layout of these.
* [feature] Introduce metric tools via devtools
* [fixed] Lots of transitvity edge cases

[Compare v0.1.3..v0.2.0](https://github.com/mbj/to_source/ompare/v0.1.3...v0.2.0)
