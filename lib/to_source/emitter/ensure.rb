module ToSource
  class Emitter
    class Ensure < self

      handle(Rubinius::AST::Ensure)

    private

      def dispatch
        emit('begin')
        indent
        visit(node.body)
        unindent
        emit(:ensure)
        indent
        visit(node.ensure)
        unindent
        emit_end
      end
    end
  end
end
