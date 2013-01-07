module ToSource
  class Emitter
    class BlockArgument < self

      handle(Rubinius::AST::BlockArgument)

    private

      def dispatch
        emit('&')
        emit(node.name)
      end

    end
  end
end
