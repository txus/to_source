module ToSource
  class Emitter
    class ScopedName < self

      handle(Rubinius::AST::ScopedClassName)
      handle(Rubinius::AST::ScopedModuleName)
      handle(Rubinius::AST::ScopedConstant)

      def dispatch
        visit(node.parent)
        emit('::')
        emit(node.name)
      end

    end
  end
end
