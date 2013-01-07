module ToSource
  class Emitter
    class Iter < self

      handle(Rubinius::AST::Iter19)

    private

      def dispatch
        emit(' do')
        run(FormalArguments::Block)
        indent
        visit(node.body)
        unindent
        emit_end
      end
    end
  end
end
