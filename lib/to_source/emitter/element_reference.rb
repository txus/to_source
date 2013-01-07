module ToSource
  class Emitter
    class ElementReference < self

    private

      def dispatch
        visit(node.receiver)
        emit('[')
        visit(node.arguments.array.first)
        emit(']')
      end
    end
  end
end
