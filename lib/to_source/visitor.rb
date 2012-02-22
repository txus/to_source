module ToSource
  class Visitor
    def initialize
      @output = []
    end

    def newline
      @output.push "\n"
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
      newline
    end

    def fixnum_literal(node, parent)
      emit node.value.to_s
    end
  end
end
