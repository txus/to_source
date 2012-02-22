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
    end

    def fixnum_literal(node, parent)
      emit node.value.to_s
    end

    def string_literal(node, parent)
      emit ?" << node.string.to_s << ?"
    end
  end
end
