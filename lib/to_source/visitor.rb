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

    # Return handler registry
    #
    # @return [Hash]
    #
    # @api private
    #
    def self.registry
      @registry ||= {}
    end

    # Register handler class
    #
    # @param [Class:Rubinius::AST::Node] node_klass
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.register(node_klass)
      registry[node_klass]=self
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
      handler = self.class.registry.fetch(node.class) do
        name = node.node_name
        name = "#{name}_def" if %w(class module).include?(name)
        __send__(name, node)
        nil
      end

      handler.run(self, node) if handler
    end

    # Emit file
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def file(node)
      emit('__FILE__')
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

    # Emit alias
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def alias(node)
      emit("alias #{node.to.value} #{node.from.value}")
    end

    # Emit match operator
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def match3(node)
      dispatch(node.value)
      emit(' =~ ')
      dispatch(node.pattern)
    end

    # Emit break
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def break(node)
      emit('break')
      if node.value.class != Rubinius::AST::NilLiteral
        emit('(')
        dispatch(node.value)
        emit(')')
      end
    end

    # Emit next
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def next(node)
      emit('next')
    end

    # Emit conditional element assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def op_assign1(node)
      receiver(node)
      emit('[')
      dispatch(node.arguments.array.first)
      emit('] ||= ')
      dispatch(node.value)
    end

    # Emit attribute assignment after merge
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def op_assign2(node)
      dispatch(node.receiver)
      emit('.')
      emit(node.name)
      emit(' |= ')
      dispatch(node.value)
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
      rescue_condition(node.rescue)
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

      if node.next
        dispatch(node.next)
      end
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

    # Emit dynamic string body
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dynamic_string_body(node)
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
    end

    # Emit dynamic execute string
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dynamic_execute_string(node)
      emit('`')
      dynamic_string_body(node)
      emit('`')
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
      dynamic_string_body(node)
      emit('"')
    end

    # Emit dynamic symbol
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dynamic_symbol(node)
      emit(':')
      dynamic_string(node)
    end

    # Emit singleton class inheritance
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def s_class(node)
      emit('class << ')
      dispatch(node.receiver)
      nl
      # FIXME: attr_reader missing on Rubinius::AST::SClass
      scope = node.instance_variable_get(:@body)
      body = scope.body
      if body
        body(body)
      end
      kend
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

    # Emit class variable assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def class_variable_assignment(node)
      if node.value
        emit("#{node.name} = ")
        dispatch(node.value)
      else
        emit(node.name)
      end
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

    # Emit class variable
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def class_variable_access(node)
      emit(node.name)
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

    # Emit global variable access
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def global_variable_access(node)
      emit(node.name)
    end

    # Emit global variable assignment
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def global_variable_assignment(node)
      if(node.value)
        emit("%s = " % node.name)
        dispatch(node.value)
      else
        emit(node.name)
      end
    end

    # Emit nref global variable access
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def nth_ref(node)
      emit("$#{node.which}")
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

    # Emit defined check
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def defined(node)
      emit('defined?(')
      dispatch(node.expression)
      emit(')')
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

    # Emit execute string
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def execute_string(node)
      emit("`#{node.string.inspect[1..-2]}`")
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
      if node.block
        dispatch(node.block)
      end
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
      emit('super')
      # Stupid hack to ensure super() is emitted, this lib needs a redesign!
      arguments = node.arguments
      empty = arguments.array.empty? && !arguments.splat && !node.block
      emit('()') if empty
      arguments(node)
    end

    # Emit concat args
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def concat_args(node)
      emit('[')
      array_body(node.array.body)
      emit(', ')
      emit('*')
      dispatch(node.rest)
      emit(']')
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
      emit(Regexp.new(node.source).inspect)
    end


    # Emit receiver
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [true]
    #   returns true if there is an explicit receiver
    #
    # @return [false]
    #   returns false otherwise
    #
    # @api private
    #
    def receiver(node)
      unless node.receiver.is_a?(Rubinius::AST::Self) and node.privately
        dispatch(node.receiver)
        true
      else
        false
      end
    end

    UNARY_OPERATORS = %w(
      ! ~ -@ +@
    ).map(&:to_sym).to_set.freeze

    UNARY_MAPPING = {
      :-@ => :-,
      :+@ => :+,
    }.freeze

    # Emit unary operator
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [true]
    #   if node was emitted
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def unary_operator(node)
      name = node.name

      if UNARY_OPERATORS.include?(name)
        emit(UNARY_MAPPING.fetch(name, name))
        dispatch(node.receiver)
        return true
      end

      false
    end

    # Emit send node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def send(node)
      return if unary_operator(node)

      if receiver(node)
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
          dispatch(block)
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
    def arguments(node, open='(', close=')')
      arguments = node.arguments
      array, block = arguments.array, node.block

      return if array.empty? and block.nil? and arguments.splat.nil?

      emit(open)

      array_body(array)
      is_block_pass = block.kind_of?(Rubinius::AST::BlockPass)

      empty = array.empty?

      if arguments.splat
        emit(', ') unless empty
        dispatch(arguments.splat)
        empty = false
      end

      if is_block_pass
        emit(', ') unless empty
        block_pass(block)
      end

      emit(close)

      if block and !is_block_pass
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
      emit('self')
    end

    # Emit element reference
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def element_reference(node)
      dispatch(node.receiver)
      arguments(node, '[', ']')
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
      if node.name == :[]
        return element_reference(node)
      end

      return if process_binary_operator(node)

      if receiver(node)
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

    # Emit splat value
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def splat_value(node)
      emit('*')
      dispatch(node.value)
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
      emit(' do')

      arguments = node.arguments
      unless arguments.required.empty?
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
      binary(node, '&&')
    end

    # Call block while emitting parantheses
    #
    # @return [undefined]
    #
    # @api private
    #
    def parantheses
      emit('(')
      yield
      emit(')')
    end

    # Emit binary operation
    #
    # @param [Rubnius::AST::Node] node
    #
    # @param [Symbol] symbol
    #   the operation symbol
    #
    # @api private
    #
    def binary(node, symbol)
      parantheses do
        parantheses { dispatch(node.left) }
        emit(" #{symbol} ")
        parantheses { dispatch(node.right) }
      end
    end

    # Emit binary shortcut
    #
    # @param [Rubinius::AST::Node] node
    #
    # @param [Symbol] symbol
    #
    # @api private
    #
    def binary_shortcut(node, symbol)
      parantheses do
        dispatch(node.left)
        emit(" #{symbol} ")
        parantheses { dispatch(node.right.value) }
      end
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
      binary(node, '||')
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
      binary_shortcut(node, :'&&=')
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
      binary_shortcut(node, :'||=')
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

    # Emit toplevel class name
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def toplevel_class_name(node)
      emit("::#{node.name}")
    end

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

    # Emit pattern variable
    #
    # @param [Rubinius::AST::PatternVariable] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def pattern_variable(node)
      emit(node.name)
    end

    # Emit pattern arguments
    #
    # @param [Rubinius::AST::PatternArguments] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def pattern_arguments(node)
      emit('(')
      arguments = node.arguments.body
      arguments.each_with_index do |argument, index|
        dispatch(argument)
        emit(', ') unless index == arguments.size - 1
      end
      emit(')')
    end

    # Emit formal arguments as shared between ruby18 and ruby19 mode
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def formal_arguments_generic(node, open, close)
      required, defaults, splat, block_arg = node.required, node.defaults, node.splat, node.block_arg
      return unless required.any? or defaults or splat or block_arg

      emit(open)

      required.each_with_index do |node, index|
        if node.kind_of?(Rubinius::AST::Node)
          dispatch(node)
        else
          emit(node)
        end
        emit(', ') unless index == required.size-1
      end

      empty = required.empty?

      if defaults
        emit(', ') unless empty
        dispatch(node.defaults)
        empty = false
      end

      if splat
        emit(', ') unless empty
        emit('*')
        empty = false
        unless splat == :@unnamed_splat
          emit(splat)
        end
      end

      if block_arg
        emit(', ') unless empty

        dispatch(block_arg)
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

    # Emit begin
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def begin(node)
      emit('begin')
      nl

      body = node.rescue
      case body
      when Rubinius::AST::Rescue
        # Rescue is reserved keyword
        __send__(:rescue,body)
      when Rubinius::AST::Ensure
        # Ensure is reserved keyword
        __send__(:ensure,body)
      else
        body(node.rescue)
      end

      kend
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
    alias_method :block_pass19, :block_pass

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

    OPERATORS = %w(
      + - * / & | && || << >> == 
      === != <= < <=> > >= =~ !~ ^ 
      **
    ).map(&:to_sym).to_set

    # Process binary operator
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [self]
    #   if node was handled
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def process_binary_operator(node)
      name = node.name
      return unless OPERATORS.include?(name)

      operand = node.arguments.array[0]

      parantheses do
       parantheses { dispatch(node.receiver) }
       emit(" #{name.to_s} ")
       parantheses { dispatch(operand) }
      end
    end
  end
end
