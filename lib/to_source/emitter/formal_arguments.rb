module ToSource

  class Emitter

    class FormalArguments < self

    private

      def any?
        required? or defaults? or splat? or block_arg?
      end

      def required
        arguments.required
      end

      def required?
        required.any?
      end

      def defaults
        arguments.defaults
      end

      def defaults?
        !!defaults
      end

      def splat
        arguments.splat
      end

      def splat?
        !!splat
      end

      def block_arg
        arguments.block_arg
      end

      def block_arg?
        !!block_arg
      end

      def emit_required
        array = required
        max = array.length - 1
        array.each_with_index do |member, index|
          if member.kind_of?(Rubinius::AST::Node)
            visit(member)
          else
            emit(member)
          end
          emit(', ') if index < max
        end
      end

      def emit_defaults
        return unless defaults?
        emit(', ') if required?
        visit(defaults)
      end

      def emit_splat
        return unless splat?

        emit(', ') if required? or defaults?
        emit('*')
        value = splat
        unless value == :@unnamed_splat
          emit(value)
        end
      end

      def emit_block_arg
        return unless block_arg?
        emit(', ') if required? or defaults? or splat?
        visit(block_arg)
      end

      def arguments
        node.arguments
      end

      def dispatch
        return unless any?

        util = self.class

        emit(util::OPEN)

        emit_required
        emit_defaults
        emit_splat
        emit_block_arg

        emit(util::CLOSE)
      end

      class Block < self
        OPEN = ' |'.freeze
        CLOSE = '|'.freeze
      end

      class Method < self
        OPEN = '('.freeze
        CLOSE = ')'.freeze
      end
    end
  end
end
