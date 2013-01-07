module ToSource
  class Emitter
    class When < self

      handle(Rubinius::AST::When)

    private

      def dispatch
        emit('when ')
        emit_single
        emit_conditions
        emit_splat
        indent
        visit(node.body)
        unindent
      end

      def emit_single
        single = node.single
        visit(single) if single
      end

      def emit_splat
        splat = node.splat
        return unless splat
        visit(splat)
      end

      def emit_conditions
        conditions = node.conditions 
        return unless conditions
        run(Util::DelimitedBody, conditions.body)
      end

    end
  end
end
