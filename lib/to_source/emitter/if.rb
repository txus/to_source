module ToSource
  class Emitter
    class If < self

      handle(Rubinius::AST::If)

    private

      def if_branch?
        !node.body.kind_of?(Rubinius::AST::NilLiteral)
      end

      def else_branch?
        !node.else.kind_of?(Rubinius::AST::NilLiteral)
      end

      def dispatch
        if else_branch? and !if_branch?
          run(Unless, node)
          return
        end

        normal_dispatch
      end

      def normal_dispatch
        emit('if ')
        visit(node.condition)
        emit_if_branch
        emit_else_branch
        emit('end')
      end

      def emit_if_branch
        indent
        visit(node.body)
        unindent
      end

      def emit_else_branch
        body = node.else
        return unless else_branch?
        emit('else')
        indent
        visit(body)
        unindent
      end
    end
  end
end
