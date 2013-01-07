module ToSource
  class Emitter
    class BinaryOperator < self

    private

      def dispatch
        emit('(')
        visit(node.left)
        emit(')')
        space
        emit(self.class::SYMBOL)
        space
        emit('(')
        visit(node.right)
        emit(')')
      end

      class Or < self

        SYMBOL = :'||'

        handle(Rubinius::AST::Or)

      end

      class And < self

        SYMBOL = :'&&'

        handle(Rubinius::AST::And)

      end
    end
  end
end
