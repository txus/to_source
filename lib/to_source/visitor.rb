module ToSource
  class Visitor
    def initialize
      @output = []
      @indentation = 0
    end

    def self.run(node)
      visitor = new
      visitor.dispatch(node)
      visitor.output
    end

    def dispatch(node)
      name = node.node_name
      name = "#{name}_def" if %w[ class module ].include?(name)
      __send__(name, node)
    end

    def output
      @output.join
    end

  private

    def kend
      emit(current_indentation)
      emit('end')
    end

    def emit(code)
      @output << code
    end

    def current_indentation
      '  ' * @indentation
    end

    def nl
      emit("\n")
    end

    def class_def(node)
      emit('class ')

      dispatch(node.name)

      superclass = node.superclass
      unless superclass.is_a?(Rubinius::AST::NilLiteral)
        emit ' < '
        dispatch(superclass)
      end
      nl

      dispatch(node.body)

      kend
    end

    def class_name(node)
      emit(node.name)
    end

    def module_name(node)
      emit(node.name)
    end

    def module_def(node)
      emit "module "
      dispatch(node.name)
      nl

      dispatch(node.body)

      kend
    end

    def empty_body(*)
      # do nothing
    end

    def class_scope(node)
      body(node.body)
    end

    def module_scope(node)
      body(node.body)
    end

    def local_variable_assignment(node)
      emit "%s = " % node.name
      dispatch(node.value)
    end

    def local_variable_access(node)
      emit(node.name)
    end

    def instance_variable_assignment(node)
      emit("%s = " % node.name)
      dispatch(node.value)
    end

    def instance_variable_access(node)
      emit(node.name)
    end

    def fixnum_literal(node)
      emit(node.value.to_s)
    end

    def float_literal(node)
      emit(node.value.to_s)
    end

    def string_literal(node)
      emit(node.string.inspect)
    end

    def symbol_literal(node)
      emit ':' << node.value.to_s
    end

    def true_literal(node)
      emit 'true'
    end

    def false_literal(node)
      emit 'false'
    end

    def nil_literal(node)
      emit 'nil'
    end

    def array_literal(node)
      body = node.body

      emit '['
      body.each_with_index do |node, index|
        dispatch(node)
        emit ', ' unless body.length == index + 1 # last element
      end
      emit ']'
    end

    def hash_literal(node)
      body = node.array.each_slice(2)

      emit '{'
      body.each_with_index do |slice, index|
        key, value = slice

        dispatch(key)
        emit " => "
        dispatch(value)

        emit ', ' unless body.to_a.length == index + 1 # last element
      end
      emit '}'
    end

    def range(node)
      dispatch(node.start)
      emit '..'
      dispatch(node.finish)
    end

    def range_exclude(node)
      dispatch(node.start)
      emit '...'
      dispatch(node.finish)
    end

    def regex_literal(node)
      emit '/'
      emit node.source
      emit '/'
    end

    def send(node)
      if node.name == :'!'
        emit '!'
        dispatch(node.receiver)
        return
      end

      unless node.receiver.is_a?(Rubinius::AST::Self) and node.privately
        dispatch(node.receiver)
        emit '.'
      end

      emit(node.name)

      if(node.block)
        emit(' ')
        dispatch(node.block)
      end
    end

    def self(node)
      emit 'self'
    end

    def send_with_arguments(node)
      return if process_binary_operator(node) # 1 * 2, a / 3, true && false

      unless node.receiver.is_a?(Rubinius::AST::Self)
        dispatch(node.receiver)
        emit('.')
      end

      emit(node.name)

      emit('(')
      dispatch(node.arguments)
      emit(')')
      if node.block
        emit(' ')
        dispatch(node.block) 
      end
    end

    def actual_arguments(node)
      body = node.array
      body.each_with_index do |argument, index|
        dispatch(argument)
        emit(', ') unless body.length == index + 1 # last element
      end
    end

    def iter(node)
      emit('do')

      arguments = node.arguments
      unless arguments.names.empty?
        emit(' ')
        iter_arguments(node.arguments)
      end

      nl
      body(node.body)

      kend
    end

    def iter_arguments(node)
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

    def iter19(node)
      emit('do')

      arguments = node.arguments
      unless arguments.names.empty?
        emit(' ')
        formal_arguments_generic(node.arguments,'|','|')
      end

      nl
      body(node.body)

      kend
    end


    def block(node)
      body = node.array
      body.each_with_index do |expression,index|
        emit(current_indentation)
        dispatch(expression)
        nl unless body.length == index+1
      end
    end

    def not(node)
      emit('!')
      dispatch(node.value)
    end

    def and(node)
      dispatch(node.left)
      emit(' && ')
      dispatch(node.right)
    end

    def or(node)
      dispatch(node.left)
      emit(' || ')
      dispatch(node.right)
    end

    def op_assign_and(node)
      dispatch(node.left)
      emit(' && ')
      dispatch(node.right)
    end

    def op_assign_or(node)
      dispatch(node.left)
      emit(' || ')
      dispatch(node.right)
    end
    alias_method :op_assign_or19, :op_assign_or

    def toplevel_constant(node)
      emit('::')
      emit(node.name)
    end

    def constant_access(node)
      emit(node.name)
    end

    def scoped_constant(node)
      dispatch(node.parent)
      emit('::')
      emit(node.name)
    end
    alias_method :scoped_class_name, :scoped_constant
    alias_method :scoped_module_name, :scoped_constant

    def if(node)
      body, else_body = node.body, node.else

      keyword = 'if'

      if node.body.is_a?(Rubinius::AST::NilLiteral) && !node.else.is_a?(Rubinius::AST::NilLiteral)
        body, else_body = else_body, body
        keyword = 'unless'
      end

      emit(keyword)
      emit(' ')
      dispatch(node.condition)
      nl

      body(body)

      if else_body.is_a?(Rubinius::AST::NilLiteral)
        kend
        return
      end

      emit('else')
      nl

      body(else_body)

      kend
    end

    def body(node)
      @indentation+=1
      node = 
        case node
        when Rubinius::AST::Block, Rubinius::AST::EmptyBody
          node
        else
          Rubinius::AST::Block.new(node.line, [node])
        end

      dispatch(node)
      nl
    ensure
      @indentation-=1
    end

    def while(node)
      emit 'while '
      dispatch(node.condition)
      nl

      body(node.body)

      kend
    end

    def until(node)
      emit 'until '
      dispatch(node.condition)
      nl

      body(node.body)

      kend
    end

    def formal_arguments_generic(node,open,close)
      return if node.names.empty? 
      required, defaults, splat = node.required, node.defaults, node.splat

      emit(open)
      emit(required.join(', '))

      empty = required.empty?

      if defaults
        emit(', ') unless empty
        dispatch(node.defaults)
      end

      if node.splat
        emit(', ') unless empty
        emit('*')
        emit(node.splat)
      end

      if node.block_arg
        emit(', ') unless empty

        dispatch(node.block_arg)
      end

      emit(close)
    end

    def formal_arguments(node)
      formal_arguments_generic(node,'(',')')
    end

    alias_method :formal_arguments19, :formal_arguments

    def block_argument(node)
      emit('&')
      emit(node.name)
    end

    def default_arguments(node)
      last = node.arguments.length - 1
      node.arguments.each_with_index do |argument, index|
        dispatch(argument)
        emit(',') unless index == last
      end
    end

    def define(node)
      emit('def ')

      emit(node.name)
      dispatch(node.arguments)
      nl

      body(node.body)
      kend
    end

    def define_singleton(node)
      emit('def ')
      dispatch(node.receiver)
      emit('.')
      dispatch(node.body)
    end

    def define_singleton_scope(node)
      emit(node.name)
      dispatch(node.arguments)
      nl
      
      body(node.body)

      kend
    end

    def return(node)
      emit 'return '
      dispatch(node.value)
    end


    def process_binary_operator(node)
      operators = %w(+ - * / & | <<).map(&:to_sym)
      return false unless operators.include?(node.name)
      return false if node.arguments.array.length != 1

      operand = node.arguments.array[0]

      unless node.receiver.is_a?(Rubinius::AST::Self)
        dispatch(node.receiver)
      end

      emit(" #{node.name.to_s} ")
      dispatch(operand)
    end
  end
end
