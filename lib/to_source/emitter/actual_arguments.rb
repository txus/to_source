module ToSource
  class Emitter
    class ActualArguments < self

      handle(Rubinius::AST::ActualArguments)

      def any?
        normal? or splat?
      end

    private

      def dispatch
        emit_normal
        emit_splat
      end

      def array
        node.array
      end

      def splat?
        !!splat
      end

      def normal?
        !array.empty?
      end

      def splat
        node.splat
      end

      def emit_normal
        run(Util::DelimitedBody, array)
      end

      def emit_splat
        return unless splat?
        emit(', ') if normal?
        visit(splat) 
      end
    end
  end
end
