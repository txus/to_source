module ToSource
  class Emitter
    class BinaryOperatorMethod < self

    private

      def dispatch
        emit('(')
        visit(left)
        emit(')')
        space
        emit(node.name)
        space
        emit('(')
        visit(right)
        emit(')')
      end

      def left
        node.receiver
      end

      def right
        node.arguments.array.first
      end
    end
  end
end
