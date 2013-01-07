module ToSource
  class Emitter
    class ZSuper < self

      handle(Rubinius::AST::ZSuper)

    private

      def dispatch
        emit('super')
        block = node.block
        visit(block) if block
      end
    end
  end
end
