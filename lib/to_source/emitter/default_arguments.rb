module ToSource
  class Emitter
    class DefaultArguments < self

      handle(Rubinius::AST::DefaultArguments)

    private

      def dispatch
        run(Util::DelimitedBody, node.arguments)
      end
    end
  end
end
