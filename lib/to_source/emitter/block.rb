module ToSource
  class Emitter

    class Block < self
      
      handle(Rubinius::AST::Block)

    private

      def dispatch
        array = node.array
        max = array.length-1
        array.each_with_index do |node, index|
          visit(node)
          if index < max
            new_line
          end
        end
      end

    end

  end
end
