module ToSource
  class Emitter
    class ToArray < self

      handle(Rubinius::AST::ToArray)

    private

      def dispatch
        visit(node.value)
      end
    end
  end
end
