module ToSource
  class Emitter
    class MultipleAssignment < self

      handle(Rubinius::AST::MultipleAssignment)

    private

      def dispatch
        body = node.left.body
        run(Util::DelimitedBody, node.left.body)
        emit(' = ')
        right = node.right
        if node.right.kind_of?(Rubinius::AST::ArrayLiteral)
          run(Util::DelimitedBody, right.body)
        else
          visit(right)
        end
      end
    end
  end
end
