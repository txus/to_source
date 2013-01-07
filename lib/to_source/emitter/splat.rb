module ToSource
  class Emitter
    class Splat < self

      handle(Rubinius::AST::SplatValue)
      handle(Rubinius::AST::RescueSplat)

    private

      def dispatch
        emit('*')
        visit(node.value)
      end

    end

  end
end
