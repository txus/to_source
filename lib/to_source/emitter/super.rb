module ToSource
  class Emitter
    class Super < self

      handle(Rubinius::AST::Super)

    private

      def dispatch
        emit('super')
        emit_arguments
        emit_block
      end

      def emit_arguments
        emit('(')
        emitter = visit(node.arguments)
        emit_block_pass(emitter)
        emit(')')
      end

      def block
        node.block
      end

      def block?
        !!block
      end

      def block_pass?
        block.kind_of?(Rubinius::AST::BlockPass19)
      end

      def emit_block_pass(emitter)
        return unless block? and block_pass?
        emit(', ') if emitter.any?
        visit(block)
      end

      def emit_block
        return unless block? and !block_pass?
        visit(block)
      end
    end
  end
end
