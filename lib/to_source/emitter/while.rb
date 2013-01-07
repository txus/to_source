module ToSource
  class Emitter
    class While < self

      handle(Rubinius::AST::While)

    private

      def dispatch
        emit('while ')
        visit(node.condition)
        indent
        visit(node.body)
        unindent
        emit_end
      end

    end
  end
end
