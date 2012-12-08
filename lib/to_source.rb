require 'set'
require 'melbourne'
require 'to_source/version'
require 'to_source/visitor'

# Namespace of library
module ToSource
  # Convert node to string
  #
  # @param [Rubinius::AST::Node] node
  #
  # @return [String]
  #
  # @api private
  #
  def self.to_source(node)
    Visitor.run(node)
  end
end
