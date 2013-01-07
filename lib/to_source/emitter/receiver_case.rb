module ToSource
  class Emitter
    class ReceiverCase < self

      handle(Rubinius::AST::ReceiverCase)

      def dispatch
        emit('case ')
        visit(node.receiver)
        emit_whens
        emit_else
        emit_end
      end

      def emit_else
        body = node.else
        return if body.kind_of?(Rubinius::AST::NilLiteral)
        emit('else')
        indent
        visit(body)
        unindent
      end

      def emit_whens
        first = true
        node.whens.each do |member|
          new_line if first
          first = false
          visit(member)
        end
      end

    end
  end
end
