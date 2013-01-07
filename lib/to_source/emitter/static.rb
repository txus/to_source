module ToSource
  class Emitter

    class Static < self

    private

      def dispatch
        emit(self.class::SYMBOL)
      end

      class Next < self

        handle(Rubinius::AST::Next)
        SYMBOL = :next

      end

      class Self < self
        handle(Rubinius::AST::Self)
        SYMBOL = :self
      end

      class File < self
        handle(Rubinius::AST::File)
        SYMBOL = :__FILE__
      end

    end

  end
end
