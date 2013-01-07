module ToSource
  class Emitter

    class ExecuteString < self

      handle(Rubinius::AST::ExecuteString)

      def dispatch
        emit("`#{node.string}`")
      end
    end

  end
end
