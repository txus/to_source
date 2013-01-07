module ToSource
  class Emitter
    class AttributeAssignment < self

      handle(Rubinius::AST::AttributeAssignment)

    private

      def dispatch
        visit(node.receiver)
        emit('.')
        emit(node.name)
        space
        visit(node.arguments.array.first)
      end
    end
  end
end
