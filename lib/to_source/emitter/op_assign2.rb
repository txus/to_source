module ToSource
  class Emitter
    class OpAssign2 < self

      handle(Rubinius::AST::OpAssign2)

    private

      def dispatch
        visit(node.receiver)
        emit('.')
        emit(node.name)
        emit(' |= ')
        visit(node.value)
      end
    end
  end
end
