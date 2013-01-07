module ToSource
  class Emitter
    class Until < self

      handle(Rubinius::AST::Until)

    private

      def dispatch
        emit('until ')
        visit(node.condition)
        indent
        visit(node.body)
        unindent
        emit_end
      end

    end
  end
end
