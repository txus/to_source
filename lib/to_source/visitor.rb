module ToSource
  # Converter from AST to source
  class Visitor

    # Create source code from AST node
    #
    # @param [Rubinius::AST::Node] node
    #   the node to convert to source code
    #
    # @return [String]
    #   returns the source code for ast node
    #
    # @api private
    #
    def self.run(node)
      new(node).output
    end

    # Return the source code of AST
    #
    # @return [String]
    #
    # @api private
    #
    def output
      @output.join
    end

  private

    # Initialize visitor
    # 
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(node)
      @output = []
      @indentation = 0
      dispatch(node)
    end

    # Dispatch node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dispatch(node)
      name = node.node_name
      name = "#{name}_def" if %w[ class module ].include?(name)
      __send__(name, node)
    rescue NoMethodError => exception
      node.ascii_graph
      raise exception.message
    end

    # Emit element assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def element_assignment(node)
      index, value = node.arguments.array
      dispatch(node.receiver)
      emit('[')
      dispatch(index)
      emit('] = ')
      dispatch(value)
    end

    # Emit rescue
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def rescue(node)
      body(node.body)
      dispatch(node.rescue)
    end

    # Emit rescue condition
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def rescue_condition(node)
      emit('rescue')
      if node.conditions
        body = node.conditions.body
        first = body.first
        unless body.one? and first.kind_of?(Rubinius::AST::ConstantAccess) and first.name == :StandardError
          emit(' ')
          array_body(body)
        end
      end

      if node.splat
        emit(',') if node.conditions
        emit(' ')
        dispatch(node.splat)
      end

      if node.assignment
        emit(' => ')
        emit(node.assignment.name)
      end
      nl
      body(node.body)
    end

    # Emit rescue splat
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def rescue_splat(node)
      emit('*')
      dispatch(node.value)
    end

    # Emit ensure
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def ensure(node)
      body(node.body)
      emit('ensure')
      nl
      body(node.ensure)
    end

    # Emit attribute assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def attribute_assignment(node)
      dispatch(node.receiver)
      emit('.')
      emit(node.name)
      emit(' ')
      actual_arguments(node.arguments)
    end

    # Emit body with taking care on indentation
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def body(node)
      @indentation+=1
      node = 
        case node
        when Rubinius::AST::EmptyBody
          node
        when Rubinius::AST::Block
          # Hack to correctly indent ensure or rescue
          noindent = [Rubinius::AST::Ensure, Rubinius::AST::Rescue]
          if node.array.one? && noindent.include?(node.array.first.class)
            @indentation-=1
            dispatch(node)
            return
          end
          node
        else
          Rubinius::AST::Block.new(node.line, [node])
        end

      dispatch(node)
      nl
      @indentation-=1 
    end

    # Emit end keyword
    #
    # @return [undefined]
    #
    # @api private
    #
    def kend
      emit(current_indentation)
      emit('end')
    end

    # Emit newline
    #
    # @return [undefined]
    #
    # @api private
    #
    def nl
      emit("\n")
    end

    # Emit pice of code
    #
    # @param [String] code
    #
    # @return [undefined]
    #
    # @api private
    #
    def emit(code)
      @output << code
    end

    # Return current indentation
    #
    # @return [String]
    #
    # @api private
    #
    def current_indentation
      '  ' * @indentation
    end

    # Emit dynamic literal
    #
    # @return [undefined]
    #
    # @api private
    #
    def dynamic_body(node)
    end

    # Emit dynamic regexp
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dynamic_regex(node)
      emit('/')
      emit(node.string)
      node.array.each do |member|
        case member
        when Rubinius::AST::ToString
          emit('#{')
          dispatch(member.value)
          emit('}')
        when Rubinius::AST::StringLiteral
          emit(member.string)
        end
      end
      emit('/')
    end

    # Emit dynamic string
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dynamic_string(node)
      emit('"')
      emit(node.string.inspect[1..-2])
      node.array.each do |member|
        case member
        when Rubinius::AST::ToString
          emit('#{')
          dispatch(member.value)
          emit('}')
        when Rubinius::AST::StringLiteral
          emit(member.string.inspect[1..-2])
        end
      end
      emit('"')
    end

    # Emit to array
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def to_array(node)
      dispatch(node.value)
    end

    # Emit multiple assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def multiple_assignment(node)
      body = node.left.body

      array_body(node.left.body)

      emit(' = ')

      right = node.right

      if node.right.kind_of?(Rubinius::AST::ArrayLiteral)
        array_body(right.body)
      else
        dispatch(right)
      end
    end

    # Emit constant assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def constant_assignment(node)
      dispatch(node.constant)
      emit(' = ')
      dispatch(node.value)
    end

    # Emit negation
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def negate(node)
      emit('-')
      dispatch(node.value)
    end

    # Emit class definition
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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

    # Emit class name
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def class_name(node)
      emit(node.name)
    end

    # Emit module name
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def module_name(node)
      emit(node.name)
    end

    # Emit module definition
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def module_def(node)
      emit "module "
      dispatch(node.name)
      nl

      dispatch(node.body)

      kend
    end

    # Emit empty body
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def empty_body(node)
      # do nothing
    end

    # Emit class scope
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def class_scope(node)
      body(node.body)
    end

    # Emit module scope
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def module_scope(node)
      body(node.body)
    end

    # Emit local variable assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def local_variable_assignment(node)
      if node.value
        emit("#{node.name} = ")
        dispatch(node.value)
      else
        emit(node.name)
      end
    end

    # Emit local variable access
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def local_variable_access(node)
      emit(node.name)
    end

    # Emit instance variable assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def instance_variable_assignment(node)
      if(node.value)
        emit("%s = " % node.name)
        dispatch(node.value)
      else
        emit(node.name)
      end
    end

    # Emit instance variable access
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def instance_variable_access(node)
      emit(node.name)
    end

    # Emit fixnum literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def fixnum_literal(node)
      emit(node.value.to_s)
    end

    # Emit float literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def float_literal(node)
      emit(node.value.to_s)
    end

    # Emit string literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def string_literal(node)
      emit(node.string.inspect)
    end

    # Emit symbol literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def symbol_literal(node)
      emit ":#{node.value.to_s}"
    end

    # Emit true literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def true_literal(node)
      emit 'true'
    end

    # Emit false literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def false_literal(node)
      emit 'false'
    end

    # Emit nil literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def nil_literal(node)
      emit 'nil'
    end


    # Emit argumentless super
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def z_super(node)
      emit('super')
    end

    # Emit super
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def super(node)
      z_super(node)
      arguments(node)
    end
 
    # Emit array body
    #
    # @param [Array] body
    #
    # @return [undefined]
    #
    # @api private
    #
    def array_body(body)
      body.each_with_index do |node, index|
        dispatch(node)
        emit ', ' unless body.length == index + 1 # last element
      end
    end

    # Emit array literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def array_literal(node)
      emit('[')
      array_body(node.body)
      emit(']')
    end


    # Emit emtpy array literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def empty_array(node)
      emit('[]')
    end

    # Emit hash literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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

    # Emit inclusive range literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def range(node)
      dispatch(node.start)
      emit '..'
      dispatch(node.finish)
    end

    # Emit exlusive range literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def range_exclude(node)
      dispatch(node.start)
      emit '...'
      dispatch(node.finish)
    end

    # Emit range literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def regex_literal(node)
      emit '/'
      emit node.source
      emit '/'
    end

    # Emit send literal
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def send(node)
      if node.name == :'!'
        emit('!')
        dispatch(node.receiver)
        return
      end

      unless node.receiver.is_a?(Rubinius::AST::Self) and node.privately
        dispatch(node.receiver)
        emit('.')
      end

      emit(node.name)

      block = node.block

      if(block)
        if block.kind_of?(Rubinius::AST::BlockPass)
          emit('(')
          block_pass(block)
          emit(')')
        else
          iter(block)
        end
      end
    end

    # Emit arguments
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def arguments(node)
      array, block = node.arguments.array, node.block

      return if array.empty? and block.nil?

      emit('(')

      array_body(array)
      is_block_pass = block.kind_of?(Rubinius::AST::BlockPass)

      if is_block_pass
        emit(', ') unless array.empty?
        block_pass(block)
      end

      emit(')')

      if block and !is_block_pass
        emit(' ')
        dispatch(node.block) 
      end
    end

    # Emit self 
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def self(node)
      emit 'self'
    end


    # Emit send with arguments 
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def send_with_arguments(node)
      return if process_binary_operator(node) # 1 * 2, a / 3, true && false

      unless node.receiver.is_a?(Rubinius::AST::Self)
        dispatch(node.receiver)
        emit('.')
      end

      emit(node.name)

      arguments(node)
    end

    # Emit yield
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def yield(node)
      emit('yield')
      arguments(node)
    end

    # Emit receiver case statment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def receiver_case(node)
      emit('case ')
      dispatch(node.receiver)
      nl
      node.whens.each do |branch|
        dispatch(branch)
      end
      else_body = node.else
      unless else_body.kind_of?(Rubinius::AST::NilLiteral)
        emit('else')
        nl
        body(else_body)
      end
      kend
    end

    # Emit when
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def when(node)
      emit('when ')
      if node.single
        dispatch(node.single)
      end
      if node.conditions
        array_body(node.conditions.body)
      end
      if node.splat
        dispatch(node.splat)
      end
      nl
      body(node.body)
    end

    # Emit splat when
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def splat_when(node)
      emit('*')
      dispatch(node.condition)
    end

    # Emit acutal arguments
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def actual_arguments(node)
      array_body(node.array)
    end

    # Emit iteration
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def iter(node)
      emit(' do')

      arguments = node.arguments
      unless arguments.names.empty?
        emit(' ')
        iter_arguments(node.arguments)
      end

      nl
      body(node.body)

      kend
    end

    # Emit iteration arguments for ruby18 mode
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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

    # Emit iteration arguments for ruby19 mode
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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

    # Emit block
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def block(node)
      body = node.array
      body.each_with_index do |expression,index|
        emit(current_indentation)
        dispatch(expression)
        nl unless body.length == index+1
      end
    end

    # Emit not
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def not(node)
      emit('!')
      dispatch(node.value)
    end

    # Emit and
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def and(node)
      dispatch(node.left)
      emit(' && ')
      dispatch(node.right)
    end

    # Emit or
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def or(node)
      dispatch(node.left)
      emit(' || ')
      dispatch(node.right)
    end

    # Emit and operation with assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def op_assign_and(node)
      dispatch(node.left)
      emit(' && ')
      dispatch(node.right)
    end

    # Emit or operation with assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def op_assign_or(node)
      dispatch(node.left)
      emit(' || ')
      dispatch(node.right)
    end
    alias_method :op_assign_or19, :op_assign_or

    # Emit toplevel constant 
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def toplevel_constant(node)
      emit('::')
      emit(node.name)
    end

    # Emit constant accesws
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def constant_access(node)
      emit(node.name)
    end

    # Emit scoped constant
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def scoped_constant(node)
      dispatch(node.parent)
      emit('::')
      emit(node.name)
    end
    alias_method :scoped_class_name, :scoped_constant
    alias_method :scoped_module_name, :scoped_constant

    # Emit if expression
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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

    # Dispatch node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def while(node)
      emit 'while '
      dispatch(node.condition)
      nl

      body(node.body)

      kend
    end

    # Emit until
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def until(node)
      emit 'until '
      dispatch(node.condition)
      nl

      body(node.body)

      kend
    end

    # Emit formal arguments as shared between ruby18 and ruby19 mode
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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

    # Emit formal arguments for ruby19 and ruby18
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def formal_arguments(node)
      formal_arguments_generic(node,'(',')')
    end
    alias_method :formal_arguments19, :formal_arguments

    # Emit block argument
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def block_argument(node)
      emit('&')
      emit(node.name)
    end

    # Emit default arguments
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def default_arguments(node)
      last = node.arguments.length - 1
      node.arguments.each_with_index do |argument, index|
        dispatch(argument)
        emit(',') unless index == last
      end
    end

    # Emit define on instances
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def define(node)
      emit('def ')

      emit(node.name)
      dispatch(node.arguments)
      nl

      body(node.body)
      kend
    end

    # Emit define on singletons
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def define_singleton(node)
      emit('def ')
      dispatch(node.receiver)
      emit('.')
      dispatch(node.body)
    end

    # Emit singleton scope
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def define_singleton_scope(node)
      emit(node.name)
      dispatch(node.arguments)
      nl
      
      body(node.body)

      kend
    end

    # Emit block pass 
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def block_pass(node)
      emit('&')
      dispatch(node.body)
    end

    # Emit return statement
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def return(node)
      emit('return')
      if node.value
        emit(' ')
        dispatch(node.value)
      end
    end

    # Process binary operator
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
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
