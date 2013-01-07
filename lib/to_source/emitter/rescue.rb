module ToSource
  class Emitter

    class Rescue < self

      handle(Rubinius::AST::Rescue)

    private

      def dispatch
        emit('begin')
        indent
        visit(node.body)
        unindent
        visit(node.rescue)
        emit_end
      end

    end

  end
end
