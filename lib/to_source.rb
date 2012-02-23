require "to_source/version"
require "to_source/core_ext/node"
require "to_source/visitor"

module ToSource
  # Public: Converts the node back to its original source code.
  #
  # Returns the String output.
  def to_source
    visitor = Visitor.new
    lazy_visit(visitor)
    visitor.output
  end
end

Rubinius::AST::Node.send :include, ToSource
