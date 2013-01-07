module ToSource
  class Emitter

    class Toplevel < self

      handle(Rubinius::AST::ToplevelClassName)
      handle(Rubinius::AST::ToplevelConstant)

      def dispatch
        emit('::')
        emit(node.name)
      end
    end

  end
end
