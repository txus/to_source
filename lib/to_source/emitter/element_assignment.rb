module ToSource
  class Emitter
    class ElementAssignment < self

      handle(Rubinius::AST::ElementAssignment)

    private

      def dispatch
        index, value = node.arguments.array
        visit(node.receiver)
        emit('[')
        visit(index)
        emit('] = ')
        visit(value)
      end
    end
  end
end
