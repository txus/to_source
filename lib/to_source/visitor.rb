module ToSource
  class Visitor
    def initialize
      @output = []
      @indentation = 0
    end

    def emit(code)
      @output.push code
    end

    def output
      @output.join
    end

    def current_indentation
      '  ' * @indentation
    end

    def local_variable_assignment(node, parent)
      emit "%s = " % node.name
      node.value.lazy_visit self, node
    end

    def local_variable_access(node, parent)
      emit node.name
    end

    def fixnum_literal(node, parent)
      emit node.value.to_s
    end

    def float_literal(node, parent)
      emit node.value.to_s
    end

    def string_literal(node, parent)
      emit '"' << node.string.to_s << '"'
    end

    def symbol_literal(node, parent)
      emit ':' << node.value.to_s
    end

    def true_literal(node, parent)
      emit 'true'
    end

    def false_literal(node, parent)
      emit 'false'
    end

    def nil_literal(node, parent)
      emit 'nil'
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

    def range_exclude(node, parent)
      node.start.lazy_visit self, node
      emit '...'
      node.finish.lazy_visit self, node
    end

    def regex_literal(node, parent)
      emit '/'
      emit node.source
      emit '/'
    end

    def send(node, parent)
      unless node.receiver.is_a?(Rubinius::AST::Self)
        node.receiver.lazy_visit self, node
        emit '.'
      end
      emit node.name

      if node.block
        emit ' '
        node.block.lazy_visit self, node if node.block
      end
    end

    def send_with_arguments(node, parent)
      return if process_binary_operator(node, parent) # 1 * 2, a / 3, true && false

      unless node.receiver.is_a?(Rubinius::AST::Self)
        node.receiver.lazy_visit self, node
        emit '.'
      end

      emit node.name
      emit '('
      node.arguments.lazy_visit self, node
      emit ')'
      if node.block
        emit ' '
        node.block.lazy_visit self, node if node.block
      end
    end

    def actual_arguments(node, parent)
      body = node.array
      body.each_with_index do |argument, index|
        argument.lazy_visit self, parent
        emit ', ' unless body.length == index + 1 # last element
      end
    end

    def iter_arguments(node, parent)
      body = if node.prelude == :single
        Array(node.arguments.name)
      else
        node.arguments.left.body.map(&:name)
      end

      emit '|'
      body.each_with_index do |argument, index|
        emit argument.to_s
        emit ', ' unless body.length == index + 1 # last element
      end
      emit '|'
    end

    def iter(node, parent)
      emit 'do'

      if node.arguments && node.arguments.arity != -1
        emit ' '
        node.arguments.lazy_visit self, parent
      end

      emit "\n"
      @indentation += 1

      if node.body.is_a?(Rubinius::AST::Block)
        node.body.lazy_visit self, parent, true
      else
        emit current_indentation
        node.body.lazy_visit self, parent
      end

      emit "\n"
      emit 'end'
    end

    def block(node, parent, indent=false)
      body = node.array
      body.each_with_index do |expression, index|
        emit current_indentation if indent
        expression.lazy_visit self, parent
        emit "\n" unless body.length == index + 1 # last element
      end
    end

    def not(node, parent)
      emit '!'
      node.value.lazy_visit self, parent
    end

    def and(node, parent)
      node.left.lazy_visit self, node
      emit ' && '
      node.right.lazy_visit self, node
    end

    def or(node, parent)
      node.left.lazy_visit self, node
      emit ' || '
      node.right.lazy_visit self, node
    end

    def op_assign_and(node, parent)
      node.left.lazy_visit self, node
      emit ' && '
      node.right.lazy_visit self, node
    end

    def op_assign_or(node, parent)
      node.left.lazy_visit self, node
      emit ' || '
      node.right.lazy_visit self, node
    end

    def constant_access(node, parent)
      emit node.name
    end

    def scoped_constant(node, parent)
      node.parent.lazy_visit self, node
      emit '::'
      emit node.name
    end

    def if(node, parent)
      body, else_body = node.body, node.else
      keyword = 'if'

      if node.body.is_a?(Rubinius::AST::NilLiteral) && !node.else.is_a?(Rubinius::AST::NilLiteral)

        body, else_body = else_body, body
        keyword = 'unless'
      end

      emit keyword << ' '
      node.condition.lazy_visit self, node
      emit "\n"

      @indentation += 1

      if body.is_a?(Rubinius::AST::Block)
        body.lazy_visit self, parent, true
      else
        emit current_indentation
        body.lazy_visit self, parent
      end

      emit "\n"

      if else_body.is_a?(Rubinius::AST::NilLiteral)
        emit 'end'
        return
      end

      emit "else\n"

      if else_body.is_a?(Rubinius::AST::Block)
        else_body.lazy_visit self, parent, true
      else
        emit current_indentation
        else_body.lazy_visit self, parent
      end

      emit "\n"
      emit 'end'
    end

    def unless(node, parent)
    end

    private

    def process_binary_operator(node, parent)
      operators = %w(+ - * / & | <<).map(&:to_sym)
      return false unless operators.include?(node.name)
      return false if node.arguments.array.length != 1

      operand = node.arguments.array[0]

      unless node.receiver.is_a?(Rubinius::AST::Self)
        node.receiver.lazy_visit self, node
      end

      emit ' ' << node.name.to_s << ' '
      operand.lazy_visit self, node
    end
  end
end
