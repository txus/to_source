module ToSource
  class Emitter

    class Access < self

      handle(Rubinius::AST::ConstantAccess)
      handle(Rubinius::AST::InstanceVariableAccess)
      handle(Rubinius::AST::LocalVariableAccess)
      handle(Rubinius::AST::ClassVariableAccess)
      handle(Rubinius::AST::GlobalVariableAccess)
      handle(Rubinius::AST::PatternVariable)

    private

      def dispatch
        emit(node.name)
      end
    end

  end
end
