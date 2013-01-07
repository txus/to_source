module ToSource
  class Emitter
    class Alias < self

      handle(Rubinius::AST::Alias)

    private

      def dispatch
        emit('alias ')
        emit(node.to.value)
        space
        emit(node.from.value)
      end
    end
  end
end
