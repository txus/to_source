module ToSource

  class Emitter

    class Assignment < self

    private

      def dispatch
        emit_name
        val = value

        if val
          emit(' = ')
          visit(val)
        end
      end

      def value
        node.value
      end

      class Constant < self

        handle(Rubinius::AST::ConstantAssignment)

        def emit_name
          visit(node.constant)
        end

      end

      class Variable < self

        handle(Rubinius::AST::LocalVariableAssignment)
        handle(Rubinius::AST::InstanceVariableAssignment)
        handle(Rubinius::AST::GlobalVariableAssignment)
        handle(Rubinius::AST::ClassVariableAssignment)

        def emit_name
          emit(node.name)
        end

        def name
          node.name
        end

      end

    end

    class AssignmentOperator < self

      def dispatch
        visit(node.left)
        space
        emit(self.class::SYMBOL)
        space
        emit('(')
        visit(node.right.value)
        emit(')')
      end

      class Or < self

        SYMBOL = :'||='

        handle(Rubinius::AST::OpAssignOr19)

      end

      class And < self

        SYMBOL = :'&&='

        handle(Rubinius::AST::OpAssignAnd)

      end
    end
  end
end
