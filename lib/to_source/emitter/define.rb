module ToSource
  class Emitter

    class DefineSingleton < self

      handle(Rubinius::AST::DefineSingleton)

    private

      def dispatch
        emit('def ')
        visit(node.receiver)
        emit('.')
        visit(node.body)
      end
    end

    class Define < self

    private

      def shared_dispatch
        emit(node.name)
        emit_arguments
        indent
        visit(node.body)
        unindent
        emit_end
      end

      def emit_arguments
        run(FormalArguments::Method)
      end

      class Singleton < self

        handle(Rubinius::AST::DefineSingletonScope)

      private

        def dispatch
          shared_dispatch
        end

      end

      class Instance < self

        handle(Rubinius::AST::Define)

      private

        def dispatch
          emit('def ')
          shared_dispatch
        end

      end
    end

  end
end
