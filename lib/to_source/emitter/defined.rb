module ToSource
  class Emitter
    class Defined < self

      handle(Rubinius::AST::Defined)

    private

      def dispatch
        emit('defined?(')
        visit(node.expression)
        emit(')')
      end
    end
  end
end
