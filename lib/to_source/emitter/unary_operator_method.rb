module ToSource
  class Emitter
    class UnaryOperatorMethod < self

      UNARY_MAPPING = {
        :-@ => :-,
        :+@ => :+,
      }.freeze

    private

      def dispatch
        name = node.name
        emit(UNARY_MAPPING.fetch(name, name))
        visit(node.receiver)
      end

    end
  end
end
