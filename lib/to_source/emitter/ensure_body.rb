module ToSource
  class Emitter
    class EnsureBody < self

    private

      def dispatch
        visit(node.body)
        unindent
        emit('ensure')
        indent
        visit(node.ensure)
        unindent
      end
    end
  end
end
