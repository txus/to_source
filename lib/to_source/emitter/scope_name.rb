module ToSource
  class Emitter
    class ScopeName < self

      handle(Rubinius::AST::ClassName)
      handle(Rubinius::AST::ModuleName)

    private

      def dispatch
        emit(node.name)
      end

    end
  end
end
