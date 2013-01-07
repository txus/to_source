module ToSource
  class Emitter
    class ConcatArguments < self

      handle(Rubinius::AST::ConcatArgs)

    private

      def dispatch
        emit('[')
        run(Util::DelimitedBody, node.array.body)
        emit(', ')
        emit('*')
        visit(node.rest)
        emit(']')
      end

    end
  end
end
