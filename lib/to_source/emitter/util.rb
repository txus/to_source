
module ToSource
  class Emitter
    class Util < self
      class DelimitedBody < self

      private

        def dispatch
          max = node.length - 1
          node.each_with_index do |member, index|
            visit(member)
            emit(', ') if index < max
          end
        end

      end
    end
  end
end
