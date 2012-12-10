# v0.2.4 2012-12-07

* [fixed] Emplit send with splat and block argument correctly

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
