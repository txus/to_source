module ToSource
  class Emitter
    class Module < self

      handle(Rubinius::AST::Module)

    private

      def dispatch
        emit(:module)
        space
        visit(node.name)
        indent
        visit(node.body)
        unindent
        emit_end
      end

    end
  end
end
