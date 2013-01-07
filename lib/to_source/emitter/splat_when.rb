module ToSource
  class Emitter
    class SplatWhen < self

      handle(Rubinius::AST::SplatWhen)

    private

      def dispatch
        emit('*')
        visit(node.condition)
      end
    end
  end
end
