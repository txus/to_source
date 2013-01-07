module ToSource
  class Emitter
    class PatternArguments < self

      handle(Rubinius::AST::PatternArguments)

    private

      def dispatch
        emit('(')
        run(Util::DelimitedBody, node.arguments.body)
        emit(')')
      end
    end
  end
end
