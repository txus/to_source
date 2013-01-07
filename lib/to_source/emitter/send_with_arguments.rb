module ToSource
  class Emitter
    class SendWithArguments < self

      handle(Rubinius::AST::SendWithArguments)

    private

      def dispatch
        if node.name == :[]
          run(ElementReference, node)
          return
        end
        if binary_operator_method?
          run(BinaryOperatorMethod, node)
          return
        end
        normal_dispatch
      end

      BINARY_OPERATORS = %w(
        + - * / & | && || << >> == 
        === != <= < <=> > >= =~ !~ ^ 
        **
      ).map(&:to_sym).to_set

      def binary_operator_method?
        BINARY_OPERATORS.include?(node.name)
      end

      def emit_receiver
        unless node.privately
          visit(node.receiver)
          emit('.')
        end
      end

      def normal_dispatch
        emit_receiver
        emit(node.name)
        emit_arguments
      end

      def emit_arguments
        emit('(')
        emitter = visit(node.arguments)
        emit_block_pass(emitter)
        emit(')')
      end

      def emit_block_pass(emitter)
        block = node.block

        if block && block.kind_of?(Rubinius::AST::BlockPass19)
          emit(', ') if emitter.any?
          visit(block)
        end
      end
    end
  end
end
