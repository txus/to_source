module ToSource
  class Visitor
    def initialize
      @output = []
    end

    def emit(code)
      @output.push code
    end

    def output
      @output.join
    end

    def local_variable_assignment(node, parent)
      emit "%s = " % node.name
      node.value.lazy_visit self, node
    end

    def fixnum_literal(node, parent)
      emit node.value.to_s
    end

    def float_literal(node, parent)
      emit node.value.to_s
    end

    def string_literal(node, parent)
      emit ?" << node.string.to_s << ?"
    end

    def symbol_literal(node, parent)
      emit ?: << node.value.to_s
    end

    def array_literal(node, parent)
      body = node.body

      emit '['
      body.each_with_index do |node, index|
        node.lazy_visit self, node
        emit ', ' unless body.length == index + 1 # last element
      end
      emit ']'
    end

    def hash_literal(node, parent)
      body = node.array.each_slice(2)

      emit '{'
      body.each_with_index do |slice, index|
        key, value = slice

        key.lazy_visit self, node
        emit " => "
        value.lazy_visit self, node

        emit ', ' unless body.to_a.length == index + 1 # last element
      end
      emit '}'
    end

    def range(node, parent)
      node.start.lazy_visit self, node
      emit '..'
      node.finish.lazy_visit self, node
    end

    def regex_literal(node, parent)
      emit ?/
      emit node.source
      emit ?/
    end

    def send(node, parent)
      unless node.receiver.is_a?(Rubinius::AST::Self)
        node.receiver.lazy_visit self, node
        emit ?.
      end
      emit node.name
    end

    def send_with_arguments(node, parent)
      send(node, parent)
      emit ?(
      node.arguments.lazy_visit self, node
      emit ?)
    end

    def actual_arguments(node, parent)
      body = node.array
      body.each_with_index do |argument, index|
        argument.lazy_visit self, parent
        emit ', ' unless body.length == index + 1 # last element
      end
    end
  end
end
