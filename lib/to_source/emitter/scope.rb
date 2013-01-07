module ToSource
  class Emitter

    class Scope < self

      handle(Rubinius::AST::ClassScope)
      handle(Rubinius::AST::ModuleScope)
      handle(Rubinius::AST::SClassScope)

    private

      def dispatch
        visit(node.body)
      end
    end

  end
end
