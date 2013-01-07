module ToSource
  class Emitter

    class KeywordValue < self

    private

      def dispatch
        emit(self.class::SYMBOL)
        if value?
          emit('(')
          visit(node.value)
          emit(')')
        end
      end

      class Return < self
        SYMBOL = :return
        handle(Rubinius::AST::Return)

      private

        def value?
          !!node.value
        end
      end

      class Break < self

        handle(Rubinius::AST::Break)

        SYMBOL = :break

        def value?
          !node.value.kind_of?(Rubinius::AST::NilLiteral)
        end
      end
    end

  end
end
