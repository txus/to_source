module ToSource
  class Emitter
    class Class < self

      handle(Rubinius::AST::Class)

    private

      def dispatch
        emit(:class)
        space
        visit(node.name)
        superclass
        indent
        visit(node.body)
        unindent
        emit_end
      end

      def superclass
        superclass = node.superclass
        return if superclass.kind_of?(Rubinius::AST::NilLiteral)
        emit(' < ')
        visit(superclass)
      end
    end
  end
end
