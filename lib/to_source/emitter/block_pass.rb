module ToSource
  class Emitter
    class BlockPass < self

      handle(Rubinius::AST::BlockPass19)

    private

      def dispatch
        emit('&')
        visit(node.body)
      end
    end
  end
end
