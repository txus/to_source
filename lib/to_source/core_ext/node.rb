module Rubinius
  module AST
    class Node
      # Public: Works like #visit, but it doesn't visit the children just yet;
      # instead, lets the visitor decide when and how to do it.
      #
      # visitor - The visitor object. It must respond to methods named after the
      #           node names.
      #
      # Returns nothing.
      def lazy_visit(visitor, parent=nil, indent=false)
        name = node_name
        name = "#{name}_def" if %w[ class module ].include?(name)

        args = [name, self, parent]
        args << true if indent

        visitor.__send__ *args
      end
    end
  end
end
