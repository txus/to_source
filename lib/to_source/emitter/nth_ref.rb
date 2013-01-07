module ToSource
  class Emitter
    class NthRef < self

      handle(Rubinius::AST::NthRef)

    private

      def dispatch
        emit("$#{node.which}")
      end
    end
  end
end
