module ToSource
  class Emitter
    class ToString < self

      handle(Rubinius::AST::ToString)

    private

      def dispatch
        emit('#{')
        visit(node.value)
        emit('}')
      end
    end
  end
end
