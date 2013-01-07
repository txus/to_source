module ToSource
  class Emitter
    class Begin < self

      handle(Rubinius::AST::Begin)

    private

      def dispatch
        emit('begin')
        emit_body
        emit_end
      end

      def emit_body
        indent

        body = node.rescue

        if body.kind_of?(Rubinius::AST::Rescue)
          emit_rescue(body)
          return
        end

        if body.kind_of?(Rubinius::AST::Ensure)
          emit_ensure(body)
          return
        end

        visit(body)
        unindent
      end

      def emit_ensure(node)
        visit(node.body)
        unindent
        emit(:ensure)
        indent
        visit(node.ensure)
        unindent
      end

      def emit_rescue(node)
        visit(node.body)
        unindent
        visit(node.rescue)
      end

    end
  end
end
