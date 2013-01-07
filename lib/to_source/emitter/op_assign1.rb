module ToSource
  class Emitter
    class OpAssign1 < self

      handle(Rubinius::AST::OpAssign1)

    private

      def dispatch
        visit(node.receiver)
        emit('[')
        visit(node.arguments.array.first)
        emit('] ||= ')
        visit(node.value)
      end
    end
  end
end
