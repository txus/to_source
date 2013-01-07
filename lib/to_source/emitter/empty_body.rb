module ToSource
  class Emitter

    class EmptyBody < self

      handle(Rubinius::AST::EmptyBody)

      def dispatch
      end
    end

  end
end
