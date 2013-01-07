module ToSource
  class Emitter
    class Send < self

      handle(Rubinius::AST::Send)

      UNARY_OPERATORS = %w(
        ! ~ -@ +@
      ).map(&:to_sym).to_set.freeze

    private

      def unary_operator_method?
        UNARY_OPERATORS.include?(node.name)
      end

      def dispatch
        if unary_operator_method?
          run(UnaryOperatorMethod, node)
          return
        end

        normal_dispatch
      end

      def normal_dispatch
        unless node.privately
          visit(node.receiver)
          emit('.')
        end

        emit(node.name)
        emit_block
      end

      def emit_block
        block = node.block
        return unless block
        pass = block.kind_of?(Rubinius::AST::BlockPass19)
        emit('(') if pass
        visit(node.block)
        emit(')') if pass
      end

    end
  end
end
