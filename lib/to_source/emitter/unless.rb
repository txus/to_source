module ToSource
  class Emitter
    class Unless < self
      
      def dispatch
        emit('unless ')
        visit(node.condition)
        indent
        visit(node.else)
        unindent
        emit_end
      end
    end
  end
end
