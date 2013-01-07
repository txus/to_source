module ToSource
  class Emitter
    class Match3 < self

      handle(Rubinius::AST::Match3)

    private

      def dispatch
        visit(node.value)
        emit(' =~ ')
        visit(node.pattern)
      end
    end
  end
end
