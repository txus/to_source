module ToSource
  class Emitter

    class SingletonClass < self

      handle(Rubinius::AST::SClass)

      def dispatch
        emit(:class)
        space
        emit(:<<)
        space
        visit(node.receiver)
        indent
        # FIXME: attr_reader missing on Rubinius::AST::SClass
        visit(node.instance_variable_get(:@body))
        unindent
        emit_end
      end

    end
  end
end
